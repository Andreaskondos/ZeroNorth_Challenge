const AWS = require("aws-sdk");
const s3 = new AWS.S3();

exports.handler = async (event) => {
  try {
    for (const record of event.Records) {
      const bucketName = record.s3.bucket.name;
      const objectKey = record.s3.object.key;
      console.log(`Processing object ${objectKey} from bucket ${bucketName}.`);

      // Get the file contents from S3 file
      const params = {
        Bucket: bucketName,
        Key: objectKey,
      };
      const response = await s3.getObject(params).promise();
      const fileContents = JSON.parse(response.Body.toString("utf-8"));
      console.log("__CONTENTS__", fileContents);

      // Now time to calculate the sum of all the numbers in the JSON file
      const numbers = fileContents.numbers || []; // Ensure numbers is an array or default to an empty array
      const sum = numbers.reduce((acc, num) => acc + num, 0);
      console.log(`The sum of all the numbers in the JSON file is: ${sum}`);
      console.log(`FILE: ${objectKey} | SUM: ${sum}`);
    }
  } catch (err) {
    console.error(`Error while triggering Lambda function: ${err?.message}`);
    throw err;
  }
};
