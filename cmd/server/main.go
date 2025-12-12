package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/izinga/robustest-web/internal/app/handler"
)

func main() {
	// Set Gin mode based on environment
	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	// Static files
	r.Static("/assets", "./assets")

	// Routes
	r.GET("/", handler.HomePage)
	r.GET("/features", handler.FeaturesPage)
	r.GET("/pricing", handler.PricingPage)
	r.GET("/security", handler.SecurityPage)
	r.GET("/about", handler.AboutPage)
	r.GET("/contact", handler.ContactPage)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server starting on http://localhost:%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
