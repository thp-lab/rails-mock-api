document.addEventListener('DOMContentLoaded', function () {
  const userPreference = localStorage.getItem('theme') || 'dark-mode';
  document.body.classList.add(userPreference);
});

// Function to toggle between light and dark mode
function toggleTheme() {
  const body = document.body;
  const isDarkMode = body.classList.contains('dark-mode');

  // Toggle classes
  body.classList.toggle('dark-mode', !isDarkMode);
  body.classList.toggle('light-mode', isDarkMode);

  // Save preference
  localStorage.setItem('theme', isDarkMode ? 'light-mode' : 'dark-mode');
}