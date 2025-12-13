// Mobile menu toggle
document.addEventListener('DOMContentLoaded', function() {
  const mobileMenuBtn = document.getElementById('mobile-menu-btn');
  const mobileMenu = document.getElementById('mobile-menu');

  if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener('click', function() {
      mobileMenu.classList.toggle('hidden');
    });
  }

  // Close mobile menu when clicking outside
  document.addEventListener('click', function(event) {
    if (mobileMenu && !mobileMenu.contains(event.target) && !mobileMenuBtn.contains(event.target)) {
      mobileMenu.classList.add('hidden');
    }
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      if (href !== '#') {
        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      }
    });
  });

  // Header scroll effect
  const header = document.querySelector('header');
  if (header) {
    let lastScrollY = window.scrollY;

    window.addEventListener('scroll', function() {
      const currentScrollY = window.scrollY;

      if (currentScrollY > 100) {
        header.classList.add('shadow-md');
      } else {
        header.classList.remove('shadow-md');
      }

      lastScrollY = currentScrollY;
    });
  }

  // Form submission handling
  const contactForm = document.querySelector('form');
  if (contactForm) {
    contactForm.addEventListener('submit', function(e) {
      e.preventDefault();

      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.textContent;

      // Show loading state
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<span class="spinner"></span> Sending...';

      // Simulate form submission (replace with actual HTMX/fetch call)
      setTimeout(function() {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Message Sent!';
        submitBtn.classList.remove('bg-blue-600');
        submitBtn.classList.add('bg-green-600');

        // Reset after 3 seconds
        setTimeout(function() {
          submitBtn.textContent = originalText;
          submitBtn.classList.remove('bg-green-600');
          submitBtn.classList.add('bg-blue-600');
          contactForm.reset();
        }, 3000);
      }, 1500);
    });
  }

  // Intersection Observer for animations
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };

  const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-fade-in');
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  // Observe elements with data-animate attribute
  document.querySelectorAll('[data-animate]').forEach(el => {
    observer.observe(el);
  });
});

// HTMX event handlers
document.body.addEventListener('htmx:beforeRequest', function(evt) {
  // Add loading state to target element
  const target = evt.detail.target;
  if (target) {
    target.classList.add('opacity-50');
  }
});

document.body.addEventListener('htmx:afterRequest', function(evt) {
  // Remove loading state
  const target = evt.detail.target;
  if (target) {
    target.classList.remove('opacity-50');
  }
});

document.body.addEventListener('htmx:responseError', function(evt) {
  console.error('HTMX request failed:', evt.detail.error);
});
