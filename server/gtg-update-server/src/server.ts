import express, { type Request, type Response } from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const ADMIN_SECRET = process.env.ADMIN_SECRET || 'super-secret-key';
const DATA_FILE = path.join(import.meta.dirname, '../data/versions.json');

app.get('/api/v1/check-update', (req: Request, res: Response) => {
  try {
    const platform = req.query.platform as string;
    const versionCodeStr = req.query.versionCode as string;

    if (!platform || !versionCodeStr) {
      return res.status(400).json({ error: 'Missing platform or versionCode' });
    }

    const versionCode = parseInt(versionCodeStr, 10);

    // Read the latest version config
    if (!fs.existsSync(DATA_FILE)) {
      return res.status(500).json({ error: 'Server data not found' });
    }

    const fileData = fs.readFileSync(DATA_FILE, 'utf-8');
    const versions = JSON.parse(fileData);

    const platformData = versions[platform];
    if (!platformData) {
      return res.status(404).json({ error: `Platform ${platform} not found` });
    }

    // Check maintenance mode
    if (platformData.maintenance?.isActive) {
      return res.json({
        updateRequired: false,
        updateType: 'NONE',
        maintenance: platformData.maintenance
      });
    }

    // Check version
    let updateType = 'NONE';
    let updateRequired = false;

    if (versionCode < platformData.versionCode) {
      updateRequired = true;
      updateType = platformData.updateType || 'OPTIONAL';
    }

    return res.json({
      updateRequired,
      updateType,
      latestVersion: {
        code: platformData.versionCode,
        name: platformData.versionName,
      },
      title: platformData.title,
      message: platformData.message,
      storeUrl: platformData.storeUrl,
      maintenance: { isActive: false }
    });

  } catch (error) {
    console.error('Error handling check-update:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/v1/admin/version', (req: Request, res: Response) => {
  try {
    const secret = req.header('X-Admin-Secret');
    if (secret !== ADMIN_SECRET) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const newVersions = req.body;
    
    // Create dir if not exists
    const dir = path.dirname(DATA_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(DATA_FILE, JSON.stringify(newVersions, null, 2), 'utf-8');
    return res.json({ success: true, message: 'Version info updated successfully' });

  } catch (error) {
    console.error('Error handling admin update:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(PORT, () => {
  console.log(`Update server is running on http://localhost:${PORT}`);
});
