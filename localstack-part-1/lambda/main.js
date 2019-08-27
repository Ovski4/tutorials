'use strict';

const AWS = require('aws-sdk');

AWS.config.update({
    region: 'ap-southeast-2',
    endpoint: 'http://localstack:4569'
});

class DynamoDBService {
    constructor() {
        this.docClient = new AWS.DynamoDB.DocumentClient({ apiVersion: '2012-08-10' });
    }

    async increment(id) {
        return new Promise(async (resolve, reject) => {
            try {
                const count = await this.getCount(id);
                var params = {
                    TableName: 'table_1',
                    Item: {
                        count: count + 1,
                        id: id
                    }
                };
    
                this.docClient.put(params, function(err, data) {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(data);
                    }
                });
            } catch (err) {
                reject(err);
            }
        });
    }

    async getCount(id) {
        return new Promise(async (resolve, reject) => {
            var params = {
                TableName: 'table_1',
                Key: {id}
            };

            this.docClient.get(params, function(err, data) {
                if (err) {
                    reject(err);
                } else {
                    resolve(data['Item'] ? data['Item']['count'] : 0);
                }
            });
        });
    }
}

exports.handler = async (event, context, callback) => {
    try {
        const dynamoDBService = new DynamoDBService();
        await dynamoDBService.increment(event.id);
        callback(null, {});
    } catch (error) {
        callback(error);
    }
}