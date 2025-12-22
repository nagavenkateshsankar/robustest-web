# RobusTest Marketing Website

Enterprise mobile device lab management marketing website built with Go, Gin, Templ, HTMX, and Tailwind CSS.

## Tech Stack

- **Go** - Backend language
- **Gin** - HTTP web framework
- **Templ** - Type-safe HTML templating
- **HTMX** - Client-side interactivity
- **Tailwind CSS v4** - Styling (via @tailwindcss/cli)

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
│           ├── contact.templ
│           └── legal.templ
├── public/
│   └── assets/
│       ├── css/app.css         # Built Tailwind CSS
│       ├── js/
│       │   ├── app.js          # JavaScript
│       │   └── htmx.min.js     # HTMX library
│       └── images/             # Logo and favicon
├── src/css/input.css           # Tailwind source CSS
├── Makefile                    # Build automation
├── go.mod
└── go.sum
```

## Development

### Prerequisites

- Go 1.21+
- Node.js (for Tailwind CSS CLI)
- Templ CLI (`go install github.com/a-h/templ/cmd/templ@latest`)

### Quick Start

```bash
# Install dependencies
make deps

# Run development server
make dev
```

Server runs at http://localhost:3000

### Build Commands

```bash
make build              # Build for current platform
make build-linux        # Build for Linux
make build-all          # Build for all platforms

make release-linux      # Create Linux tarball in dist/
make release-all        # Create all platform releases
```

### Environment Variables

- `PORT` - Server port (default: 3000)
- `GIN_MODE` - Gin mode (debug/release, default: release)
- `SENDGRID_API_KEY` - SendGrid API key for contact form

## Pages

- `/` - Home
- `/features` - Features
- `/pricing` - Pricing
- `/security` - Security
- `/about` - About
- `/contact` - Contact
- `/legal` - Privacy & Terms

## License

Copyright 2025 RobusTest. All rights reserved.
