package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/izinga/robustest-web/internal/app/views/pages"
)

func HomePage(c *gin.Context) {
	pages.HomePage().Render(c.Request.Context(), c.Writer)
}

func FeaturesPage(c *gin.Context) {
	pages.FeaturesPage().Render(c.Request.Context(), c.Writer)
}

func PricingPage(c *gin.Context) {
	pages.PricingPage().Render(c.Request.Context(), c.Writer)
}

func SecurityPage(c *gin.Context) {
	pages.SecurityPage().Render(c.Request.Context(), c.Writer)
}

func AboutPage(c *gin.Context) {
	pages.AboutPage().Render(c.Request.Context(), c.Writer)
}

func ContactPage(c *gin.Context) {
	pages.ContactPage().Render(c.Request.Context(), c.Writer)
}
