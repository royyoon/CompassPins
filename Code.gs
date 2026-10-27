/**
 * Compass Pins - Google Apps Script Backend
 *
 * Deploy as a web app:
 * 1. Extensions > Apps Script
 * 2. Deploy > New deployment
 * 3. Type: Web app
 * 4. Execute as: Me
 * 5. Who has access: Anyone
 * 6. Copy the web app URL to your iOS app
 */

// Configuration - Update these
const SPREADSHEET_ID = '1ilwaETjdCODIs6r-Buj4xsLAL8MK6dEfaoPdQrfzJ8I'; // Get from URL
const IOS_CLIENT_ID = '144411573267-cadot1nebiu6tj58g54plslbgfockhri.apps.googleusercontent.com';

// Cache duration in seconds
const CACHE_DURATION = 300; // 5 minutes

/**
 * Handle GET requests
 */
function doGet(e) {
  try {
    const token = e.parameter.token || e.headers.Authorization?.replace('Bearer ', '');

    if (!token) {
      return errorResponse('Missing authentication token', 401);
    }

    const user = verifyToken(token);
    if (!user) {
      return errorResponse('Invalid token', 401);
    }

    const action = e.parameter.action;

    switch (action) {
      case 'me':
        return jsonResponse(getMe(user));
      case 'catalog':
        return jsonResponse(getCatalog());
      case 'progress':
        const circle = e.parameter.circle;
        return jsonResponse(getProgress(user, circle));
      default:
        return errorResponse('Unknown action', 400);
    }
  } catch (error) {
    Logger.log('Error in doGet: ' + error.message);
    return errorResponse(error.message, 500);
  }
}

/**
 * Handle POST requests
 */
function doPost(e) {
  const lock = LockService.getScriptLock();

  try {
    const token = e.parameter.token ||
                  JSON.parse(e.postData.contents).token ||
                  e.headers?.Authorization?.replace('Bearer ', '');

    if (!token) {
      return errorResponse('Missing authentication token', 401);
    }

    const user = verifyToken(token);
    if (!user) {
      return errorResponse('Invalid token', 401);
    }

    // Wait for lock (30 second timeout)
    lock.waitLock(30000);

    const data = JSON.parse(e.postData.contents);
    const action = data.action;

    switch (action) {
      case 'submit':
        return jsonResponse(submitPin(user, data));
      case 'review':
        return jsonResponse(reviewSubmission(user, data));
      case 'issue':
        return jsonResponse(issuePins(user, data));
      default:
        return errorResponse('Unknown action', 400);
    }
  } catch (error) {
    Logger.log('Error in doPost: ' + error.message);
    return errorResponse(error.message, 500);
  } finally {
    lock.releaseLock();
  }
}

/**
 * Verify Google ID token
 */
function verifyToken(token) {
  try {
    const cache = CacheService.getScriptCache();
    const cacheKey = 'token_' + token.substring(0, 20);
    const cached = cache.get(cacheKey);

    if (cached) {
      return JSON.parse(cached);
    }

    const url = 'https://oauth2.googleapis.com/tokeninfo?id_token=' + encodeURIComponent(token);
    const response = UrlFetchApp.fetch(url, { muteHttpExceptions: true });

    if (response.getResponseCode() !== 200) {
      return null;
    }

    const tokenInfo = JSON.parse(response.getContentText());

    // Verify audience
    if (tokenInfo.aud !== IOS_CLIENT_ID) {
      Logger.log('Invalid audience: ' + tokenInfo.aud);
      return null;
    }

    // Verify email is verified
    if (tokenInfo.email_verified !== 'true') {
      return null;
    }

    const user = {
      email: tokenInfo.email,
      name: tokenInfo.name
    };

    // Cache for 5 minutes
    cache.put(cacheKey, JSON.stringify(user), 300);

    return user;
  } catch (error) {
    Logger.log('Token verification error: ' + error.message);
    return null;
  }
}

/**
 * Get user role and their children
 */
function getMe(user) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const role = getUserRole(user.email, ss);

  if (role === 'unauthorized') {
    throw new Error('User not authorized. Contact your expedition leader.');
  }

  const result = {
    email: user.email,
    name: user.name,
    role: role
  };

  // Return children for both parents and admins (admins can have children too)
  if (role === 'parent' || role === 'admin') {
    result.children = getChildren(user.email, ss);
  }

  return result;
}

/**
 * Determine user role
 */
function getUserRole(email, ss) {
  const cache = CacheService.getScriptCache();
  const cacheKey = 'role_' + email;
  const cached = cache.get(cacheKey);

  if (cached) {
    return cached;
  }

  // Check if user is an editor (admin)
  const editors = ss.getEditors().map(e => e.getEmail());
  if (editors.includes(email)) {
    cache.put(cacheKey, 'admin', CACHE_DURATION);
    return 'admin';
  }

  // Check Families tab
  const familiesSheet = ss.getSheetByName('Families');
  if (familiesSheet) {
    const data = familiesSheet.getDataRange().getValues();
    for (let i = 1; i < data.length; i++) {
      const parentEmail = data[i][1]; // Column B: Parent Email
      if (parentEmail && parentEmail.toLowerCase() === email.toLowerCase()) {
        cache.put(cacheKey, 'parent', CACHE_DURATION);
        return 'parent';
      }
    }
  }

  return 'unauthorized';
}

/**
 * Get children for a parent
 */
function getChildren(email, ss) {
  const familiesSheet = ss.getSheetByName('Families');
  if (!familiesSheet) {
    return [];
  }

  const data = familiesSheet.getDataRange().getValues();
  const children = [];

  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    const parentEmail = row[1]; // Column B

    if (parentEmail && parentEmail.toLowerCase() === email.toLowerCase()) {
      children.push({
        circle: row[2],      // Column C
        lastName: row[3],    // Column D
        firstName: row[4]    // Column E
      });
    }
  }

  return children;
}

/**
 * Get pin catalog
 */
function getCatalog() {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const pinsSheet = ss.getSheetByName('Pins');

  if (!pinsSheet) {
    // Return hardcoded catalog if Pins tab doesn't exist
    return getHardcodedCatalog();
  }

  const data = pinsSheet.getDataRange().getValues();
  const pins = [];

  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    pins.push({
      name: row[0],           // Pin
      journey: row[1],        // Journey
      symbol: row[2],         // Symbol
      supervision: row[3],    // Supervision
      requirements: row[4]    // What to do
    });
  }

  return { pins };
}

/**
 * Hardcoded catalog fallback
 */
function getHardcodedCatalog() {
  return {
    pins: [
      { name: 'Stilts or Walking Stick', journey: 'West', supervision: 'Adult supervision', requirements: 'Build stilts or a walking stick with adult supervision.' },
      { name: 'Knife Safety', journey: 'West', supervision: 'Adult supervision', requirements: 'Demonstrate safe knife handling. Carve or whittle an object together with your adult. Present it to your Circle.' },
      { name: 'Six Knots', journey: 'West', supervision: 'Adult partnership', requirements: 'Learn and demonstrate six different knots.' },
      { name: 'Fire Safety', journey: 'West', supervision: 'Adult supervision', requirements: 'Learn fire safety rules and practice building a safe campfire.' },
      { name: 'First Aid', journey: 'West', supervision: 'Adult supervision', requirements: 'Learn basic first aid skills.' },
      { name: 'Astronomy', journey: 'West', supervision: 'Adult partnership', requirements: 'Observe the night sky and identify constellations.' },
      { name: 'Navigation', journey: 'West', supervision: 'Adult partnership', requirements: 'Learn to use a compass and map for navigation.' }
    ]
  };
}

/**
 * Get progress for explorer(s)
 */
function getProgress(user, circle) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const role = getUserRole(user.email, ss);

  if (role === 'parent') {
    // Parents see only their children
    const children = getChildren(user.email, ss);
    return getProgressForChildren(children, ss);
  } else if (role === 'admin') {
    // Admins see all or specific circle
    if (circle) {
      return getProgressForCircle(circle, ss);
    } else {
      return getProgressForAllCircles(ss);
    }
  }

  throw new Error('Unauthorized');
}

/**
 * Get progress for specific children
 */
function getProgressForChildren(children, ss) {
  const result = [];

  for (const child of children) {
    const circleSheet = ss.getSheetByName(child.circle);
    if (!circleSheet) continue;

    const explorerData = findExplorer(circleSheet, child.lastName, child.firstName);
    if (explorerData) {
      result.push(explorerData);
    }
  }

  return { explorers: result };
}

/**
 * Get progress for a circle
 */
function getProgressForCircle(circleName, ss) {
  const circleSheet = ss.getSheetByName(circleName);
  if (!circleSheet) {
    throw new Error('Circle not found: ' + circleName);
  }

  const explorers = getAllExplorers(circleSheet, circleName);
  return { circle: circleName, explorers };
}

/**
 * Get progress for all circles
 */
function getProgressForAllCircles(ss) {
  const circles = getCircleTabs(ss);
  const result = [];

  for (const circleName of circles) {
    const circleSheet = ss.getSheetByName(circleName);
    const explorers = getAllExplorers(circleSheet, circleName);
    result.push({ circle: circleName, explorers });
  }

  return { circles: result };
}

/**
 * Find explorer in circle sheet - FIXED for Vikings tab structure
 */
function findExplorer(sheet, lastName, firstName) {
  const data = sheet.getDataRange().getValues();

  // Find header row - look for "Last Name" in column B
  let headerRow = -1;
  for (let i = 0; i < Math.min(10, data.length); i++) {
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      headerRow = i;
      break;
    }
  }

  if (headerRow === -1) {
    return null;
  }

  const pinHeaders = data[headerRow];

  // Start searching one row after headers
  for (let i = headerRow + 1; i < data.length; i++) {
    const row = data[i];
    const rowLastName = row[1];   // Column B
    const rowFirstName = row[2];  // Column C

    if (!rowLastName) break;
    if (rowLastName === 'NEW') continue;

    if (rowLastName === lastName && rowFirstName === firstName) {
      return buildExplorerData(row, pinHeaders, lastName, firstName, sheet.getName());
    }
  }

  return null;
}

/**
 * Get all explorers from circle sheet - FIXED
 */
function getAllExplorers(sheet, circleName) {
  const data = sheet.getDataRange().getValues();

  // Find header row
  let headerRow = -1;
  for (let i = 0; i < Math.min(10, data.length); i++) {
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      headerRow = i;
      break;
    }
  }

  if (headerRow === -1) {
    return [];
  }

  const pinHeaders = data[headerRow];
  const explorers = [];

  for (let i = headerRow + 1; i < data.length; i++) {
    const row = data[i];
    const lastName = row[1];   // Column B
    const firstName = row[2];  // Column C

    if (!lastName) break;
    if (lastName === 'NEW') continue;

    explorers.push(buildExplorerData(row, pinHeaders, lastName, firstName, circleName));
  }

  return explorers;
}

/**
 * Build explorer data object - FIXED
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

  // FIXED: Combined the checks into one statement to avoid early exit
  for (let col = pinsStartCol; col < pinHeaders.length; col++) {
    const pinName = pinHeaders[col];

    // Skip columns that are not pin names (COMBINED CHECK - FIXED)
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

/**
 * Find explorer row - FIXED
 */
function findExplorerRow(sheet, lastName, firstName) {
  const data = sheet.getDataRange().getValues();

  // Find header row
  let headerRow = -1;
  for (let i = 0; i < Math.min(10, data.length); i++) {
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      headerRow = i;
      break;
    }
  }

  for (let i = headerRow + 1; i < data.length; i++) {
    if (data[i][1] === lastName && data[i][2] === firstName) {
      return i + 1;
    }
  }
  throw new Error('Explorer not found');
}

/**
 * Get all circle tab names
 */
function getCircleTabs(ss) {
  const sheets = ss.getSheets();
  const circles = [];

  for (const sheet of sheets) {
    const data = sheet.getDataRange().getValues();
    // Look for header row with "Last Name" and "First Name" in columns B and C
    for (let i = 0; i < Math.min(10, data.length); i++) {
      if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
        circles.push(sheet.getName());
        break;
      }
    }
  }

  return circles;
}

/**
 * Submit a pin completion
 */
function submitPin(user, data) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const role = getUserRole(user.email, ss);

  if (role !== 'parent' && role !== 'admin') {
    throw new Error('Unauthorized');
  }

  // Validate data
  if (!data.circle || !data.lastName || !data.firstName || !data.pin) {
    throw new Error('Missing required fields');
  }

  // Check if pin is already P or X
  const circleSheet = ss.getSheetByName(data.circle);
  if (!circleSheet) {
    throw new Error('Circle not found');
  }

  const explorerData = findExplorer(circleSheet, data.lastName, data.firstName);
  if (!explorerData) {
    throw new Error('Explorer not found');
  }

  const currentStatus = explorerData.pins[data.pin];
  if (currentStatus === 'P' || currentStatus === 'X') {
    throw new Error('Pin already earned or issued');
  }

  // Check if already submitted
  const submissionsSheet = getOrCreateSubmissionsSheet(ss);
  const existingSubmission = findSubmission(submissionsSheet, data.circle, data.lastName, data.firstName, data.pin);

  if (existingSubmission && existingSubmission.status === 'Submitted') {
    throw new Error('Pin already submitted and pending review');
  }

  // Add to Submissions tab
  submissionsSheet.appendRow([
    new Date(),
    data.circle,
    data.lastName,
    data.firstName,
    data.pin,
    user.email,
    data.supervisingAdult || '',
    data.note || '',
    'Submitted'
  ]);

  return { success: true, message: 'Pin submitted for review' };
}

/**
 * Review a submission
 */
function reviewSubmission(user, data) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const role = getUserRole(user.email, ss);

  if (role !== 'admin') {
    throw new Error('Only admins can review submissions');
  }

  const submissionsSheet = ss.getSheetByName('Submissions');
  if (!submissionsSheet) {
    throw new Error('Submissions sheet not found');
  }

  const submissionData = submissionsSheet.getDataRange().getValues();
  let submissionRow = -1;

  // Find submission by row number or by data
  for (let i = 1; i < submissionData.length; i++) {
    const row = submissionData[i];
    if (row[1] === data.circle &&
        row[2] === data.lastName &&
        row[3] === data.firstName &&
        row[4] === data.pin &&
        row[8] === 'Submitted') {
      submissionRow = i + 1; // 1-indexed
      break;
    }
  }

  if (submissionRow === -1) {
    throw new Error('Submission not found');
  }

  if (data.action === 'approve') {
    // Update circle sheet
    const circleSheet = ss.getSheetByName(data.circle);
    const pinCol = findPinColumn(circleSheet, data.pin);
    const explorerRow = findExplorerRow(circleSheet, data.lastName, data.firstName);

    // Re-read current value
    const currentValue = circleSheet.getRange(explorerRow, pinCol).getValue();
    if (currentValue !== 'O' && currentValue !== '') {
      throw new Error('Pin status changed. Please refresh and try again.');
    }

    // Set to P
    circleSheet.getRange(explorerRow, pinCol).setValue('P');

    // Update rockers and medallion
    updateRockersAndMedallion(circleSheet, explorerRow);

    // Update submission status
    submissionsSheet.getRange(submissionRow, 9).setValue('Approved');

    return { success: true, message: 'Pin approved' };
  } else if (data.action === 'sendBack') {
    submissionsSheet.getRange(submissionRow, 9).setValue('Needs more info');
    if (data.note) {
      submissionsSheet.getRange(submissionRow, 8).setValue(data.note);
    }
    return { success: true, message: 'Sent back for more info' };
  }

  throw new Error('Invalid action');
}

/**
 * Issue pins (mark P as X)
 */
function issuePins(user, data) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const role = getUserRole(user.email, ss);

  if (role !== 'admin') {
    throw new Error('Only admins can issue pins');
  }

  const issued = [];

  for (const item of data.pins) {
    const circleSheet = ss.getSheetByName(item.circle);
    const pinCol = findPinColumn(circleSheet, item.pin);
    const explorerRow = findExplorerRow(circleSheet, item.lastName, item.firstName);

    const currentValue = circleSheet.getRange(explorerRow, pinCol).getValue();
    if (currentValue === 'P') {
      circleSheet.getRange(explorerRow, pinCol).setValue('X');
      issued.push(item);
    }
  }

  return { success: true, issued };
}

/**
 * Helper functions
 */
function getOrCreateSubmissionsSheet(ss) {
  let sheet = ss.getSheetByName('Submissions');
  if (!sheet) {
    sheet = ss.insertSheet('Submissions');
    sheet.appendRow([
      'Timestamp', 'Circle', 'Last Name', 'First Name', 'Pin',
      'Submitted By', 'Supervising Adult', 'Note', 'Status'
    ]);
  }
  return sheet;
}

function findSubmission(sheet, circle, lastName, firstName, pin) {
  const data = sheet.getDataRange().getValues();
  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    if (row[1] === circle && row[2] === lastName && row[3] === firstName && row[4] === pin) {
      return {
        status: row[8]
      };
    }
  }
  return null;
}

function findPinColumn(sheet, pinName) {
  const data = sheet.getDataRange().getValues();

  // Find header row
  let headerRow = -1;
  for (let i = 0; i < Math.min(10, data.length); i++) {
    if (data[i][1] === 'Last Name' && data[i][2] === 'First Name') {
      headerRow = i;
      break;
    }
  }

  if (headerRow === -1) {
    throw new Error('Header row not found');
  }

  const headers = data[headerRow];
  return headers.indexOf(pinName) + 1;
}

function updateRockersAndMedallion(sheet, explorerRow) {
  // TODO: Implement rocker and medallion calculation logic
  // This requires knowing which columns are rockers and medallion
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

function errorResponse(message, code) {
  return ContentService
    .createTextOutput(JSON.stringify({ error: message, code: code }))
    .setMimeType(ContentService.MimeType.JSON);
}
