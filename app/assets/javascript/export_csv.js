// app/javascript/scripts/export_csv.js

document.addEventListener('DOMContentLoaded', () => {
  const exportButton = document.getElementById('export-csv');

  if (exportButton) {
    exportButton.addEventListener('click', async () => {
      try {
        // Fetch the CSV data from the backend
        const response = await fetch('/export-csv');

        if (!response.ok) throw new Error('Failed to download CSV');

        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);

        // Trigger the file download
        const link = document.createElement('a');
        link.href = url;
        link.download = 'export.zip';  // Changed to .zip since we're downloading a ZIP file
        link.click();

        // Clean up
        window.URL.revokeObjectURL(url);
      } catch (error) {
        alert('Error exporting CSV: ' + error.message);
      }
    });
  }
});
