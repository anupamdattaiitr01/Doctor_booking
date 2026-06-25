import app from './app.js';
import pool from './config/db.js';

const PORT = 5000; 

const server = app.listen(PORT, () => {
  console.log(`MediConnect API running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});

const gracefulShutdown = () => {
  console.log('Shutting down');
  server.close(async () => {
    console.log('Http server closed');
    try {
      await pool.end();
      console.log('Database pool closed');
      process.exit(0);
    } catch (err) {
      console.error('Error during database pool drain:', err);
      process.exit(1);
    }
  });
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);