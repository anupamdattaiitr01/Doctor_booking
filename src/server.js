import app from './app.js';
import pool from './config/db.js';
import { initializeDatabase } from './config/startDB.js';

const PORT = 5000;

const startServer = async () => {
  try {

    await initializeDatabase();

    const server = app.listen(PORT, () => {
      console.log(`🚀 MediConnect API running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
    });

    const gracefulShutdown = () => {
      console.log('\n🛑 Intercepted shutdown command. Cleaning processes...');
      server.close(async () => {
        console.log('🔒 Express HTTP server closed.');
        try {
          await pool.end();
          console.log('🔋 Database connection pool drained cleanly.');
          process.exit(0);
        } catch (err) {
          console.error('Error during connection pool drainage:', err);
          process.exit(1);
        }
      });
    };

    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);

  } catch (error) {
    console.error('💥 Server boot pipeline failed critical error:', error);
    process.exit(1);
  }
};

startServer();