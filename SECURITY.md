# Security Guide for Shvil

## 🔒 Sensitive Data Protection

### Never Commit These to Git:
- ✅ Real Supabase API keys
- ✅ Database passwords
- ✅ Authentication secrets
- ✅ Production URLs with sensitive data
- ✅ Personal API tokens

### Safe to Commit:
- ✅ Placeholder values (e.g., "YOUR_ANON_KEY_HERE")
- ✅ Public configuration structure
- ✅ Development/testing configurations
- ✅ Documentation and setup guides

## 🛡️ Configuration Security

### Current Setup:
1. **Config.swift** uses placeholder values by default
2. **Environment variables** are checked first for real values
3. **.gitignore** prevents accidental commits of sensitive files
4. **Validation** warns when using placeholder values

### How to Set Real Values:

#### Option 1: Environment Variables (Recommended)
```bash
# Set environment variables (not committed to git)
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-actual-anon-key"
```

#### Option 2: Build Configuration
1. Create a `Config-Release.swift` file (not in git)
2. Override the placeholder values
3. Use build configurations to include the right file

#### Option 3: Xcode Build Settings
1. Add build settings in Xcode
2. Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Reference them in Config.swift

## 🔍 Security Checklist

### Before Committing:
- [ ] No real API keys in code
- [ ] No database passwords
- [ ] No production secrets
- [ ] Placeholder values are clearly marked
- [ ] .gitignore is up to date

### Before Deploying:
- [ ] Real configuration values are set
- [ ] Environment variables are configured
- [ ] Database security policies are in place
- [ ] Authentication is properly configured

## 🚨 Security Best Practices

### Supabase Configuration:
1. **Use Row Level Security (RLS)** for all tables
2. **Limit API key permissions** to minimum required
3. **Use environment-specific projects** (dev/staging/prod)
4. **Regular key rotation** for production

### Code Security:
1. **Validate all inputs** from external sources
2. **Use parameterized queries** to prevent SQL injection
3. **Implement proper error handling** without exposing internals
4. **Log security events** for monitoring

### Data Protection:
1. **Encrypt sensitive data** at rest and in transit
2. **Implement data retention policies**
3. **Provide user data deletion** capabilities
4. **Follow GDPR/privacy regulations**

## 🔧 Testing Security

### Connection Testing:
- ✅ Test with placeholder values (should show warning)
- ✅ Test with real values (should connect successfully)
- ✅ Test with invalid values (should show error)
- ✅ Test network failure scenarios

### Configuration Validation:
- ✅ Verify no sensitive data in git history
- ✅ Confirm .gitignore is working
- ✅ Test environment variable loading
- ✅ Validate build configurations

## 📋 Incident Response

### If Sensitive Data is Committed:
1. **Immediately revoke** exposed keys/tokens
2. **Remove from git history** using git filter-branch
3. **Force push** to update remote repository
4. **Notify team** about the incident
5. **Update security procedures** to prevent recurrence

### Key Rotation Process:
1. Generate new keys in Supabase dashboard
2. Update configuration in secure environment
3. Deploy new configuration
4. Revoke old keys after verification
5. Update documentation

## 🎯 Security Goals

- **Zero sensitive data** in version control
- **Secure by default** configuration
- **Clear separation** between dev and prod
- **Easy key rotation** process
- **Comprehensive monitoring** of security events

---

**Remember: Security is everyone's responsibility. When in doubt, ask before committing sensitive data.**
