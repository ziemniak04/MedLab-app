# Security & API Configuration

## Environment Variables Setup

This project uses environment variables to securely store API keys and sensitive configuration.

### Initial Setup

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys to `.env`:**
   Open `.env` and replace `your_api_key_here` with your actual Claude API key:
   ```
   CLAUDE_API_KEY=sk-ant-api03-your-actual-key-here
   ```

3. **Never commit `.env` to git:**
   The `.env` file is already in `.gitignore` and will not be committed.

### Getting a Claude API Key

1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key to your `.env` file

### Files Overview

- **`.env`** - Contains actual API keys (NOT committed to git)
- **`.env.example`** - Template file showing required variables (committed to git)
- **`.gitignore`** - Configured to ignore `.env` files

### Security Best Practices

✅ **DO:**
- Keep your `.env` file local and never commit it
- Use `.env.example` to show what variables are needed
- Rotate API keys regularly
- Use different API keys for development and production
- Limit API key permissions when possible

❌ **DON'T:**
- Commit API keys to git
- Share your `.env` file
- Hardcode API keys in source code
- Use production keys in development

### Troubleshooting

**Error: "CLAUDE_API_KEY not found in .env file"**
- Make sure you copied `.env.example` to `.env`
- Verify `.env` contains `CLAUDE_API_KEY=your-key`
- Check that `.env` is in the project root directory

**API calls failing:**
- Verify your API key is correct
- Check that you have credits/quota on your Anthropic account
- Ensure internet connection is available

### For Team Members

When cloning this repository:
1. Copy `.env.example` to `.env`
2. Ask the team lead for API keys
3. Never commit your `.env` file

### CI/CD Setup

For continuous integration:
- Set environment variables in your CI/CD platform
- Use secrets management (GitHub Secrets, GitLab CI/CD variables, etc.)
- Never hardcode keys in CI configuration files

---

**Remember:** The `.env` file is your responsibility. Keep it safe and never share it publicly.
