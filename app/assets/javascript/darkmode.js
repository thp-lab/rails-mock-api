document.addEventListener('DOMContentLoaded', function () {
  const userPreference = localStorage.getItem('theme') || 'dark-mode';
  document.body.classList.add(userPreference);
});

// Function to toggle between light and dark mode
function toggleTheme() {
  const body = document.body;
  body.classList.toggle('dark-mode');

  // Sauvegarde la préférence dans le localStorage
  const isDarkMode = body.classList.contains('dark-mode');
  localStorage.setItem('dark-mode', isDarkMode);
}

// Charge le mode préféré au démarrage
window.onload = () => {
  const isDarkMode = localStorage.getItem('dark-mode') === 'true';
  if (isDarkMode) {
    document.body.classList.add('dark-mode');
  }
};
