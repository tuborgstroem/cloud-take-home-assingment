import express from 'express';
import fetch from 'node-fetch'; 

const app = express();
const apiUrl = process.env.CAT_API_URL;

app.get('/healthz', (_req, res) => {
  res.json({ status: 'UP', uptime: process.uptime() });
});

app.get('/random-cat-fact', async (_req, res) => {
  try {
    const response = await fetch(apiUrl);
    const data = await response.json();
    res.log.json(data);
    const catFact = data.fact;
    res.json({ catFact });
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while fetching the cat fact' });
  }
});

const PORT = 8000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});