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

    // Extract start and end times of the test suite execution
    const startTime = new Date(result.robot.$.generated);
    const endTime = new Date(result.robot.statistics[0].total[0].stat[0].$.endtime);
    const executionTime = (endTime - startTime) / 1000; // Convert to seconds

    result.robot.suite.forEach(suite => {
        suite.suite.forEach(testSuite => {
            testSuite.test.forEach(test => {
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
            });
        });
    });

    // Create a folder structure with current date and total execution time
    const currentDate = new Date().toISOString().split('T')[0];
    const folderPath = `./reports/${currentDate}/${executionTime}s`;
    if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
    }

    // Write JSON to file inside the folder
    const jsonFilePath = `${folderPath}/output.json`;
    fs.writeFileSync(jsonFilePath, JSON.stringify(jsonData, null, 4));

    console.log('Conversion completed. JSON file saved.');
});
