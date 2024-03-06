const fs = require('fs');
const { parseString } = require('xml2js');

// Read XML file
const xmlFilePath = './reports/output.xml';
const xmlData = fs.readFileSync(xmlFilePath, 'utf8');

// Parse XML to JSON
parseString(xmlData, (err, result) => {
    if (err) {
        console.error('Error parsing XML:', err);
        return;
    }

    // Extract relevant data and format it into the desired JSON structure
    const jsonData = {
        scripts: {}
    };

    // Extract start time of the first test
    let firstTestStartTime;
    // Extract end time of the last test
    let lastTestEndTime;
    
    result.robot.suite.forEach((suite, suiteIndex) => {
        suite.suite.forEach(testSuite => {
            testSuite.test.forEach((test, testIndex) => {
                const testName = test.$.name;
                const status = test.status[0].$.status;
                const owner = 'RA'; // Set owner according to your requirements
                const vps = {
                    failed: status === 'FAIL' ? 1 : 0,
                    passed: status === 'PASS' ? 1 : 0,
                    warning: 0 // Assuming no warnings in the provided XML
                };

                jsonData.scripts[testName] = {
                    status,
                    owner,
                    vps,
                    start_timestamp: test.status[0].$.starttime,
                    end_timestamp: test.status[0].$.endtime,
                    zip: '' // Set zip according to your requirements
                };
                if (suiteIndex === 0 && testIndex === 0) {
                    firstTestStartTime = test.status[0].$.starttime
                }
                lastTestEndTime = test.status[0].$.endtime
            });
        });
    });

    // Calculate elapsed time in seconds
    const elapsedTimeInSeconds = Math.floor(+new Date(lastTestEndTime) - +new Date(firstTestStartTime)) / 1000);

    const hours = Math.floor(elapsedTimeInSeconds / 3600);
    const minutes = Math.floor((elapsedTimeInSeconds % 3600) / 60);
    const seconds = elapsedTimeInSeconds % 60;
    const executionTimeString = `${hours}h${minutes}m${seconds}s`;
    
    // Create a folder structure with current date and total execution time
    const currentDate = new Date().toISOString().split('T')[0];
    const folderPath = `./reports/${currentDate}/${executionTimeString}`;
    if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
    }

    // Write JSON to file inside the folder
    const jsonFilePath = `${folderPath}/output.json`;
    fs.writeFileSync(jsonFilePath, JSON.stringify(jsonData, null, 4));

    console.log('Conversion completed. JSON file saved.');
});
