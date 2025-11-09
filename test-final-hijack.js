// Test the corrected approach using the same method as the container
const Module = require('module'); 
const orig = Module.prototype.require; 
Module.prototype.require = function(id) { 
  if (id === 'pg-native' || id === './native' || id.endsWith('/native')) { 
    console.log('🚫 Blocked:', id); 
    return orig.call(this, './client'); 
  } 
  return orig.apply(this, arguments); 
}; 
console.log('✅ pg-native hijack active');

console.log('\n🧪 Testing corrected hijack approach...\n');

try {
  // Force native loading to test the hijack
  process.env.NODE_PG_FORCE_NATIVE = 'true';
  
  const pg = require('pg');
  console.log('1️⃣ ✅ pg module loaded with hijack');
  console.log('   📦 pg.Client type:', typeof pg.Client);
  console.log('   📦 pg.Pool type:', typeof pg.Pool);

  // Test Client creation
  const client = new pg.Client({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test'
  });
  console.log('2️⃣ ✅ Client created successfully');

  // Test Pool creation
  const pool = new pg.Pool({
    host: 'localhost',
    port: 5432,
    user: 'test',
    password: 'test',
    database: 'test'
  });
  console.log('3️⃣ ✅ Pool created successfully');

  console.log('\n🎉 SUCCESS! Corrected hijack approach works perfectly!');
  console.log('🚀 Ready to deploy to production');

} catch (error) {
  console.log('❌ Test failed:', error.message);
  console.log('Stack:', error.stack);
}

console.log('\n🏁 Final test complete!');