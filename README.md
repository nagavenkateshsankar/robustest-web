# RobusTest Marketing Website

Enterprise mobile device lab management marketing website built with Go, Gin, Templ, HTMX, and Tailwind CSS.

## Tech Stack

- **Go** - Backend language
- **Gin** - HTTP web framework
- **Templ** - Type-safe HTML templating
- **HTMX** - Client-side interactivity
- **Tailwind CSS** - Styling (via CDN)

## Project Structure

```
robustest-web/
├── cmd/server/main.go          # Server entry point
├── internal/app/
│   ├── handler/pages.go        # Page handlers
│   └── views/
│       ├── layouts/base.templ  # Base layout with Header & Footer
│       └── pages/              # Page templates
│           ├── home.templ
│           ├── features.templ
│           ├── pricing.templ
│           ├── security.templ
│           ├── about.templ
│           └── contact.templ
├── assets/
│   ├── css/app.css             # Custom CSS
│   ├── js/
│   │   ├── app.js              # JavaScript
│   │   └── htmx.min.js         # HTMX library
│   └── images/                 # Logo and favicon
├── go.mod
└── go.sum
```

## Development

### Prerequisites

- Go 1.21+
- Templ CLI (`go install github.com/a-h/templ/cmd/templ@latest`)

### Run Development Server

```bash
# Generate templ files
templ generate

# Run server
go run ./cmd/server/

# Or build and run
go build -o robustest-web ./cmd/server/
./robustest-web
```

Server runs at http://localhost:3000

### Environment Variables

- `PORT` - Server port (default: 3000)
- `GIN_MODE` - Gin mode (debug/release, default: release)

## Pages

- `/` - Home
- `/features` - Features
- `/pricing` - Pricing
- `/security` - Security
- `/about` - About
- `/contact` - Contact

## License

Copyright 2024 RobusTest. All rights reserved.
