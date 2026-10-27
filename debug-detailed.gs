// Add this function to your Apps Script and run it

function debugDetailedPinReading() {
  const ss = SpreadsheetApp.openById('1ilwaETjdCODIs6r-Buj4xsLAL8MK6dEfaoPdQrfzJ8I');
  const sheet = ss.getSheetByName('Vikings');
  const data = sheet.getDataRange().getValues();

  Logger.log('=== FINDING HEADER ROWS ===');

  // Find column header row
  let columnHeaderRow = -1;
  for (let i = 0; i < 10; i++) {
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      columnHeaderRow = i;
      Logger.log('Column header row found at index: ' + i);
      break;
    }
  }

  if (columnHeaderRow === -1) {
    Logger.log('ERROR: Column header row not found!');
    return;
  }

  // Pin names are in the row ABOVE
  const pinHeaderRow = columnHeaderRow - 1;
  Logger.log('Pin header row is at index: ' + pinHeaderRow);

  const pinHeaders = data[pinHeaderRow];
  Logger.log('Pin headers row: ' + JSON.stringify(pinHeaders.slice(0, 20)));

  // Rocky's data is one row after column headers
  const rockyRowIndex = columnHeaderRow + 1;
  const rockyRow = data[rockyRowIndex];
  Logger.log('Rocky row index: ' + rockyRowIndex);
  Logger.log('Rocky row data: ' + JSON.stringify(rockyRow.slice(0, 20)));

  Logger.log('\n=== BUILDING PINS OBJECT ===');

  const pins = {};
  const pinsStartCol = 4;

  for (let col = pinsStartCol; col < Math.min(pinsStartCol + 20, pinHeaders.length); col++) {
    const pinName = pinHeaders[col]?.toString().trim();
    const value = rockyRow[col]?.toString().trim().toUpperCase();

    Logger.log('Col ' + col + ': pinName="' + pinName + '" value="' + value + '"');

    // Check skip conditions
    if (!pinName || pinName === '') {
      Logger.log('  -> SKIPPED: Empty pin name');
      continue;
    }
    if (pinName === 'PIn Symbol' || pinName.includes('Symbol')) {
      Logger.log('  -> SKIPPED: Symbol column');
      continue;
    }

    if (value === 'O' || value === 'P' || value === 'X') {
      pins[pinName] = value;
      Logger.log('  -> ADDED: ' + pinName + ' = ' + value);
    } else {
      Logger.log('  -> NOT ADDED: value "' + value + '" is not O/P/X');
    }
  }

  Logger.log('\n=== FINAL PINS OBJECT ===');
  Logger.log(JSON.stringify(pins, null, 2));
  Logger.log('Total pins found: ' + Object.keys(pins).length);
}
