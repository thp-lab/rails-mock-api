// app/javascript/scripts/export_csv.js

document.addEventListener('DOMContentLoaded', () => {
  const exportButton = document.getElementById('export-csv');

  if (exportButton) {
    exportButton.addEventListener('click', async () => {
      try {
        // Download atoms.csv
        const atomsResponse = await fetch('/export-csv?type=atoms');
        if (!atomsResponse.ok) throw new Error('Failed to download atoms CSV');
        const atomsBlob = await atomsResponse.blob();
        const atomsUrl = window.URL.createObjectURL(atomsBlob);
        const atomsLink = document.createElement('a');
        atomsLink.href = atomsUrl;
        atomsLink.download = 'atoms.csv';
        atomsLink.click();
        window.URL.revokeObjectURL(atomsUrl);

        // Small delay between downloads
        await new Promise(resolve => setTimeout(resolve, 100));

        // Download triples.csv
        const triplesResponse = await fetch('/export-csv?type=triples');
        if (!triplesResponse.ok) throw new Error('Failed to download triples CSV');
        const triplesBlob = await triplesResponse.blob();
        const triplesUrl = window.URL.createObjectURL(triplesBlob);
        const triplesLink = document.createElement('a');
        triplesLink.href = triplesUrl;
        triplesLink.download = 'triples.csv';
        triplesLink.click();
        window.URL.revokeObjectURL(triplesUrl);

      } catch (error) {
        alert('Error exporting CSV: ' + error.message);
      }
    });
  }
});
