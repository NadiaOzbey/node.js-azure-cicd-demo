import test, { before, after } from 'node:test'; //to run tests
import assert from 'node:assert/strict'; // to check results
import app from '../src/app.js';

let server;
let baseUrl;

// Start the server before tests
before(async () => {
    server = app.listen(0);

    await new Promise((resolve) => {
        server.once('listening', resolve);
    });

    const address = server.address();
    baseUrl = `http://127.0.0.1:${address.port}`;
});

// Stop the server after tests
after(async () => {
    await new Promise((resolve, reject) => {
        server.close((error) => {
            if (error) reject(error);
            else resolve();
        });
    });
});

// Test main endpoint
test('GET / should return welcome message', async () => {
    const response = await fetch(`${baseUrl}/`);

    assert.equal(response.status, 200);
    assert.equal(
        await response.text(),
        'Hello from DevOps Demo App!'
    );
});

// Test health endpoint
test('GET /health should return Healthy status', async () => {
    const response = await fetch(`${baseUrl}/health`);

    assert.equal(response.status, 200);

    const data = await response.json();

    assert.deepEqual(data, {
        status: 'Healthy'
    });
});

// Test info endpoint
test('GET /info should return application information', async () => {
    const response = await fetch(`${baseUrl}/info`);

    assert.equal(response.status, 200);

    const data = await response.json();

    assert.equal(data.application, 'DevOps Demo');
    assert.equal(data.version, '1.0.0');
    assert.equal(
        data.environment,
        process.env.NODE_ENV || 'development'
    );
});