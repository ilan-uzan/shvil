# 🔐 Shvil Security Guide

This document outlines the security measures implemented in Shvil to protect sensitive information, particularly API keys and user data.

## 🚨 Critical Security Rules

### 1. **NEVER COMMIT API KEYS**
- ❌ Never commit `.env` files to git
- ❌ Never hardcode API keys in source code
- ❌ Never share API keys in chat, email, or documentation
- ✅ Always use environment variables
- ✅ Always use the provided setup scripts

### 2. **API Key Protection**

#### OpenAI API Key Security
- **Format Validation**: Keys are validated to ensure they start with `sk-` and are 51 characters long
- **Secure Access**: Use `Configuration.getOpenAIKey()` for secure key retrieval
- **Error Handling**: Invalid keys trigger proper error messages without exposing the key
- **Environment Variables**: Keys are loaded from `OPENAI_API_KEY` environment variable

#### Supabase Configuration Security
- **URL Validation**: Supabase URLs are validated for proper format
- **Key Validation**: Anon keys are validated for proper format
- **Environment Variables**: Configuration loaded from `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### 3. **File Protection**

#### Protected Files (in .gitignore)
```
*.env
.env*
*APIKey*
*Secret*
*Token*
*Key*
*openai*
*supabase*
Configuration.swift.backup
```

#### Safe Files (can be committed)
```
environment.example
Configuration.swift
setup_environment.sh
```

## 🛡️ Security Implementation

### Configuration Management
```swift
// Secure key access with validation
public static func getOpenAIKey() throws -> String {
    guard isOpenAIConfigured else {
        throw ConfigurationError.openAINotConfigured
    }
    
    let key = openAIAPIKey
    guard key != "invalid-key-format" else {
        throw ConfigurationError.missingAPIKey
    }
    
    return key
}
```

### Key Validation
```swift
private static func isValidOpenAIKey(_ key: String) -> Bool {
    // OpenAI API keys typically start with 'sk-' and are 51 characters long
    return key.hasPrefix("sk-") && key.count == 51
}
```

### Secure Service Initialization
```swift
// AIKit with secure initialization
public convenience init() throws {
    let key = try Configuration.getOpenAIKey()
    self.init(apiKey: key)
}
```

## 🔧 Setup Instructions

### 1. Initial Setup
```bash
# Run the secure setup script
./setup_environment.sh
```

### 2. Manual Setup (Alternative)
```bash
# Create .env file with restricted permissions
touch .env
chmod 600 .env

# Add your keys (replace with actual values)
echo "SUPABASE_URL=https://your-project.supabase.co" >> .env
echo "SUPABASE_ANON_KEY=your-anon-key" >> .env
echo "OPENAI_API_KEY=sk-your-openai-key" >> .env
```

### 3. Verification
```bash
# Check that .env is not tracked by git
git status

# Verify file permissions
ls -la .env
# Should show: -rw------- (600 permissions)
```

## 🚀 Deployment Security

### Development
- Use `.env` files for local development
- Never commit `.env` files
- Use `environment.example` as a template

### Production
- Set environment variables in your deployment platform
- Use secure key management services (AWS Secrets Manager, Azure Key Vault, etc.)
- Never hardcode keys in production code

### CI/CD
- Use secure environment variables in your CI/CD pipeline
- Never log or expose API keys in build logs
- Use masked variables for sensitive data

## 🔍 Security Checklist

### Before Committing
- [ ] No `.env` files in git status
- [ ] No hardcoded API keys in source code
- [ ] All sensitive files are in `.gitignore`
- [ ] Configuration uses environment variables

### Before Sharing Code
- [ ] Remove any accidentally committed keys
- [ ] Use `git log` to check for key exposure
- [ ] Share `environment.example` instead of `.env`
- [ ] Document required environment variables

### Before Deployment
- [ ] Environment variables are set in deployment platform
- [ ] No keys in configuration files
- [ ] Proper error handling for missing keys
- [ ] Logging doesn't expose sensitive data

## 🆘 If You Accidentally Expose a Key

### Immediate Actions
1. **Revoke the key immediately** in your service provider's dashboard
2. **Generate a new key** with a new name
3. **Update your `.env` file** with the new key
4. **Check git history** for any commits containing the old key
5. **Force push** to remove the key from git history (if recent)

### Prevention
- Use `git secrets` or similar tools to scan for keys
- Set up pre-commit hooks to check for sensitive data
- Regular security audits of your codebase
- Team training on security best practices

## 📞 Support

If you have security concerns or questions:
1. Check this guide first
2. Review the `Configuration.swift` implementation
3. Test with the provided setup scripts
4. Contact the development team for assistance

---

**Remember**: Security is everyone's responsibility. When in doubt, ask before committing sensitive information.
