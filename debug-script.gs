// Add this temporary debug function to your Apps Script

function debugRockyPins() {
  const ss = SpreadsheetApp.openById('1ilwaETjdCODIs6r-Buj4xsLAL8MK6dEfaoPdQrfzJ8I');
  const sheet = ss.getSheetByName('Vikings');
  const data = sheet.getDataRange().getValues();
  
  // Find header row
  let headerRow = -1;
  for (let i = 0; i < Math.min(10, data.length); i++) {
    Logger.log('Row ' + i + ': ' + JSON.stringify(data[i].slice(0, 10)));
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      headerRow = i;
      Logger.log('>>> Found header row at index: ' + i);
      break;
    }
  }
  
  if (headerRow === -1) {
    Logger.log('ERROR: Header row not found!');
    return;
  }
  
  const pinHeaders = data[headerRow];
  Logger.log('All headers: ' + JSON.stringify(pinHeaders));
  
  // Find Rocky's row (should be headerRow + 1)
  const rockyRow = data[headerRow + 1];
  Logger.log('Rocky row data: ' + JSON.stringify(rockyRow));
  
  // Find Adventure Name column
  let adventureNameCol = -1;
  for (let col = 0; col < pinHeaders.length; col++) {
    if (pinHeaders[col] === 'Adventure Name' || pinHeaders[col] === '"Adventure Name"') {
      adventureNameCol = col;
      Logger.log('>>> Found Adventure Name at column: ' + col);
      break;
    }
  }
  
  const pinsStartCol = adventureNameCol !== -1 ? adventureNameCol + 1 : 4;
  Logger.log('Pins start at column: ' + pinsStartCol);
  
  // Log each column from pinsStartCol onwards
  for (let col = pinsStartCol; col < Math.min(pinsStartCol + 15, pinHeaders.length); col++) {
    const pinName = pinHeaders[col];
    const value = rockyRow[col];
    Logger.log('Column ' + col + ': Header="' + pinName + '", Value="' + value + '"');
  }
}
