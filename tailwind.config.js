/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{astro,html,js,jsx,ts,tsx,mdx,md}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', 'Apple Color Emoji', 'Segoe UI Emoji'],
      },
      colors: {
        ink: {
          50:  "#f7f7f8",
          100: "#efeff1",
          200: "#dcdcdf",
          300: "#c0c1c7",
          400: "#9a9daa",
          500: "#757a8b",
          600: "#585d71",
          700: "#42475a",
          800: "#2f3343",
          900: "#1f2130",
          950: "#131421",
        },
        brand: {
          50:  "#eef7ff",
          100: "#d9ecff",
          200: "#bcdcff",
          300: "#8fc5ff",
          400: "#5ea9ff",
          500: "#338fff",
          600: "#1e6fe6",
          700: "#1857b3",
          800: "#14488f",
          900: "#113b74",
          950: "#0a2548",
        }
      },
      boxShadow: {
        soft: "0 10px 30px -12px rgba(0,0,0,0.25)",
      }
    },
  },
  plugins: [require('@tailwindcss/typography')],
};
