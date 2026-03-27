import puppeteer from 'puppeteer';
import { resolve } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function buildPDF() {
  console.log('Launching browser...');
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const htmlPath = resolve(__dirname, 'playbook-v2.html');
  console.log('Loading HTML:', htmlPath);
  
  await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0', timeout: 60000 });
  
  // Wait for fonts to load
  await page.evaluateHandle('document.fonts.ready');
  console.log('Fonts loaded, generating PDF...');

  // Use CSS @page margins (already set in the HTML) instead of Puppeteer margins
  // The HTML has @page { margin: 0.75in 1in } and @page :first { margin: 0 }
  await page.pdf({
    path: resolve(__dirname, 'Executive-Intelligence-Playbook.pdf'),
    format: 'Letter',
    printBackground: true,
    preferCSSPageSize: true,
    margin: { top: 0, bottom: 0, left: 0, right: 0 },
    displayHeaderFooter: false,
  });

  console.log('✅ Executive-Intelligence-Playbook.pdf generated!');
  
  const { statSync } = await import('fs');
  const stats = statSync(resolve(__dirname, 'Executive-Intelligence-Playbook.pdf'));
  console.log(`📄 Size: ${(stats.size / 1024 / 1024).toFixed(1)}MB`);
  
  await browser.close();
}

buildPDF().catch(e => { console.error('Error:', e); process.exit(1); });
