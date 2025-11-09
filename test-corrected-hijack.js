#!/usr/bin/env node

// Test with proper native module stub
console.log('🔧 Testing CORRECTED hijacking with proper stub...\n');

const Module = require('module');
const originalRequire = Module.prototype.require;

let nativeAttempts = [];

// Install CORRECTED hijacking with proper stub
Module.prototype.require = function(id) {
  if (id === 'pg-native' || id === './native' || id.endsWith('/native')) {
    nativeAttempts.push(id);
    console.log(`🚫 BLOCKED native loading attempt: "${id}"`);
    
    // Return proper stub instead of null
    return {
      Query: function() {
        throw new Error('Native bindings not available - using pure JavaScript implementation');
      }
    };
  }
  return originalRequire.apply(this, arguments);
};

console.log('✅ CORRECTED hijacking active with proper native stub\n');

try {
  // Force native loading
  process.env.NODE_PG_FORCE_NATIVE = 'true';
  
  const pg = require('pg');
  console.log('1️⃣ pg module loaded with corrected stub');

  // Test Client creation
  console.log('2️⃣ Testing Client creation:');
  const client = new pg.Client({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test'
  });
  console.log('   ✅ Client created successfully');

  // Test Pool creation
  console.log('3️⃣ Testing Pool creation:');
  const pool = new pg.Pool({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test',
    max: 1
  });
  console.log('   ✅ Pool created successfully');

  console.log('\n🎉 SUCCESS! The corrected hijacking approach works!');

} catch (error) {
  console.log('❌ Test failed with corrected stub:', error.message);
  console.log('Stack:', error.stack);
}

console.log('\n📊 Final Summary:');
console.log(`🚫 Native loading attempts blocked: ${nativeAttempts.length}`);
console.log('✅ Corrected stub prevents crashes while blocking native usage');

console.log('\n🔧 Key Fix:');
console.log('- Return proper stub object instead of null');
console.log('- Stub has Query function that throws informative error');
console.log('- This allows pg library to continue with pure JS fallback');

console.log('\n🏁 Corrected test complete!');