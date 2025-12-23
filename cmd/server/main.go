package main

import (
	"context"
	"crypto/tls"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/izinga/robustest-web/internal/app/handler"
	"github.com/joho/godotenv"
)

// securityHeaders middleware adds security-related HTTP headers
func securityHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Prevent MIME type sniffing
		c.Header("X-Content-Type-Options", "nosniff")
		// Enable XSS filter in browsers
		c.Header("X-XSS-Protection", "1; mode=block")
		// Prevent clickjacking
		c.Header("X-Frame-Options", "DENY")
		// Referrer policy for privacy
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		// Permissions policy
		c.Header("Permissions-Policy", "geolocation=(), microphone=(), camera=()")

		c.Next()
	}
}

// cacheControl middleware sets appropriate cache headers for static assets
func cacheControl() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Set cache headers for static assets (1 year for versioned assets)
		if strings.HasPrefix(c.Request.URL.Path, "/assets") {
			c.Header("Cache-Control", "public, max-age=31536000, immutable")
		}
		c.Next()
	}
}

func main() {
	// Load .env file if present
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Set Gin mode based on environment
	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.New()

	// Add recovery middleware to recover from panics
	r.Use(gin.Recovery())

	// Add logger middleware in debug mode only
	if gin.Mode() == gin.DebugMode {
		r.Use(gin.Logger())
	}

	// Add security headers middleware
	r.Use(securityHeaders())

	// Get assets path from environment or use default
	assetsPath := os.Getenv("ASSETS_PATH")
	if assetsPath == "" {
		assetsPath = "./public"
	}

	// Static files with cache control
	r.Static("/assets", assetsPath+"/assets")

	// Health check endpoint for load balancers
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	// SEO files at root level
	r.GET("/robots.txt", func(c *gin.Context) {
		c.File(assetsPath + "/robots.txt")
	})
	r.GET("/sitemap.xml", func(c *gin.Context) {
		c.File(assetsPath + "/sitemap.xml")
	})

	// Routes
	r.GET("/", handler.HomePage)
	r.GET("/features", handler.FeaturesPage)
	r.GET("/pricing", handler.PricingPage)
	r.GET("/security", handler.SecurityPage)
	r.GET("/about", handler.AboutPage)
	r.GET("/contact", handler.ContactPage)
	r.GET("/legal", handler.LegalPage)

	// API routes
	r.POST("/api/contact", handler.SubmitContactForm)

	// Handle 404
	r.NoRoute(func(c *gin.Context) {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusNotFound, `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - RobusTest</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 min-h-screen flex items-center justify-center">
    <div class="text-center px-4">
        <h1 class="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <p class="text-xl text-gray-600 mb-8">Page not found</p>
        <a href="/" class="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors">
            Go Home
        </a>
    </div>
</body>
</html>`)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	// TLS configuration
	tlsCert := os.Getenv("TLS_CERT")
	tlsKey := os.Getenv("TLS_KEY")
	tlsEnabled := tlsCert != "" && tlsKey != ""

	// Configure the HTTP server with timeouts
	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Add TLS config if certificates are provided
	if tlsEnabled {
		srv.TLSConfig = &tls.Config{
			MinVersion: tls.VersionTLS12,
			CurvePreferences: []tls.CurveID{
				tls.X25519,
				tls.CurveP256,
			},
			CipherSuites: []uint16{
				tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,
				tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,
				tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
				tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
			},
		}
	}

	// Start server in a goroutine
	go func() {
		if tlsEnabled {
			log.Printf("Server starting on https://0.0.0.0:%s", port)
			if err := srv.ListenAndServeTLS(tlsCert, tlsKey); err != nil && err != http.ErrServerClosed {
				log.Fatalf("Server failed to start: %v", err)
			}
		} else {
			log.Printf("Server starting on http://0.0.0.0:%s", port)
			if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
				log.Fatalf("Server failed to start: %v", err)
			}
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Give outstanding requests 30 seconds to complete
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}
