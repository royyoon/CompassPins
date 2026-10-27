/**
 * Build explorer data object - FIXED VERSION
 * Replace the buildExplorerData function in your Apps Script with this
 */
function buildExplorerData(row, pinHeaders, lastName, firstName, circle) {
  const pins = {};

  // Get adventure name from column D (index 3)
  const adventureName = row[3]?.toString().trim() || '';

  // Find where "Adventure Name" column is in the header
  let adventureNameCol = -1;
  for (let col = 0; col < pinHeaders.length; col++) {
    if (pinHeaders[col] === 'Adventure Name' || pinHeaders[col] === '"Adventure Name"') {
      adventureNameCol = col;
      break;
    }
  }

  // Pins start right after "Adventure Name" column
  const pinsStartCol = adventureNameCol !== -1 ? adventureNameCol + 1 : 4;

  // FIXED: Combined the checks into one statement
  for (let col = pinsStartCol; col < pinHeaders.length; col++) {
    const pinName = pinHeaders[col];

    // Skip columns that are not pin names (combined check)
    if (!pinName || pinName.trim() === '' || pinName === 'Pin Symbol' || pinName.includes('Symbol')) {
      continue;
    }

    const value = row[col]?.toString().trim().toUpperCase();
    if (value === 'O' || value === 'P' || value === 'X') {
      pins[pinName] = value;
    }
  }

  return {
    circle,
    lastName,
    firstName,
    adventureName,
    pins
  };
}
