#!/usr/bin/env node

// Test script to verify pg-native hijacking approach
console.log('🧪 Testing pg-native hijacking approach...\n');

// Step 1: Test without hijacking
console.log('1️⃣ Testing normal pg module loading (without hijacking):');
try {
  const pg = require('pg');
  console.log('   ✅ pg module loaded successfully');
  console.log('   📦 pg.Client exists:', typeof pg.Client === 'function');
  console.log('   📦 pg.Pool exists:', typeof pg.Pool === 'function');
} catch (error) {
  console.log('   ❌ Failed to load pg:', error.message);
}

// Step 2: Simulate the hijacking we'll use
console.log('\n2️⃣ Installing module hijacking...');
const Module = require('module');
const originalRequire = Module.prototype.require;

let hijackCount = 0;
Module.prototype.require = function(id) {
  // Block any attempts to load pg-native
  if (id === 'pg-native' || id === './native' || id.endsWith('/native')) {
    hijackCount++;
    console.log(`   🚫 Blocked pg-native loading attempt #${hijackCount}: ${id}`);
    return null;
  }
  return originalRequire.apply(this, arguments);
};

console.log('   ✅ Module hijacking active');

// Step 3: Test pg module with hijacking
console.log('\n3️⃣ Testing pg module with hijacking active:');
try {
  // Clear require cache to force re-evaluation
  delete require.cache[require.resolve('pg')];
  
  const pgWithHijack = require('pg');
  console.log('   ✅ pg module loaded with hijacking');
  console.log('   📦 pg.Client exists:', typeof pgWithHijack.Client === 'function');
  console.log('   📦 pg.Pool exists:', typeof pgWithHijack.Pool === 'function');
  
  // Test creating a client (this is where pg-native would typically be loaded)
  console.log('\n4️⃣ Testing Client instantiation:');
  const client = new pgWithHijack.Client({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test'
  });
  console.log('   ✅ Client created successfully');
  console.log('   📦 Client type:', typeof client);
  
} catch (error) {
  console.log('   ❌ Failed with hijacking:', error.message);
  console.log('   📋 Stack trace:', error.stack);
}

// Step 4: Test Pool creation
console.log('\n5️⃣ Testing Pool instantiation:');
try {
  const pg = require('pg');
  const pool = new pg.Pool({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test',
    max: 1
  });
  console.log('   ✅ Pool created successfully');
  console.log('   📦 Pool type:', typeof pool);
} catch (error) {
  console.log('   ❌ Failed to create pool:', error.message);
}

// Step 5: Summary
console.log('\n📊 Test Summary:');
console.log(`   🚫 Native module loading attempts blocked: ${hijackCount}`);
console.log('   ✅ Test completed');

// Step 6: Test Knex integration (similar to what Backstage uses)
console.log('\n6️⃣ Testing Knex-style database configuration:');
try {
  const knexConfig = {
    client: 'pg',
    connection: {
      host: 'localhost',
      port: 5432,
      user: 'test',
      password: 'test',
      database: 'test'
    },
    useNullAsDefault: false
  };
  
  console.log('   ✅ Knex config created:', JSON.stringify(knexConfig, null, 2));
  
  // Try to load knex if available
  try {
    const knex = require('knex');
    console.log('   ✅ Knex module available');
    
    // Don't actually connect, just test initialization
    const db = knex(knexConfig);
    console.log('   ✅ Knex instance created successfully');
    
    // Clean up
    db.destroy();
  } catch (knexError) {
    console.log('   ⚠️  Knex not available (this is OK for basic test):', knexError.message);
  }
  
} catch (error) {
  console.log('   ❌ Knex test failed:', error.message);
}

console.log('\n🏁 Test complete!');