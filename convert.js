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

    // Write JSON to file
    const jsonFilePath = './output.json';
    fs.writeFileSync(jsonFilePath, JSON.stringify(jsonData, null, 4));

    console.log('Conversion completed. JSON file saved.');
});
