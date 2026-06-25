import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { query } from './db.js';

// 1. Properly decode the absolute file path URL (this converts '%20' back to ' ')
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const initializeDatabase = async () => {
  try {
    // 2. Safely resolve the path out of src/config and into the root directory
    const schemaPath = path.resolve(__dirname, '../../schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    console.log('🔄 Checking database and establishing schema structures...');
    await query(schemaSql);
    console.log('✅ All database tables, indexes, and safe-locks verified/initialized successfully.');
  } catch (error) {
    console.error('❌ Critical Error: Failed to execute database synchronization layout:', error);
    process.exit(1); 
  }
};