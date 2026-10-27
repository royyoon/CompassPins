// Add this function to test if your deployment has the new code

function testDeployment() {
  const ss = SpreadsheetApp.openById('1ilwaETjdCODIs6r-Buj4xsLAL8MK6dEfaoPdQrfzJ8I');
  const sheet = ss.getSheetByName('Vikings');
  
  // Simulate what the deployed code does
  const explorerData = findExplorer(sheet, 'Yoon', 'Rocky');
  
  Logger.log('Explorer data returned:');
  Logger.log(JSON.stringify(explorerData, null, 2));
  Logger.log('Number of pins: ' + Object.keys(explorerData.pins).length);
  Logger.log('Adventure name: ' + explorerData.adventureName);
}
