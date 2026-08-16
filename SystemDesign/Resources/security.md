# Security — Explanations

This file expands the checklist in `Phase14_Security.md` with concise explanations, risks, and implementation notes engineers can use when designing secure systems.

1. Security Fundamentals
- CIA Triad
  Confidentiality: protect data from unauthorized access.
  Integrity: ensure data is not tampered with.
  Availability: ensure services remain accessible.
- Authentication vs Authorization
  Authentication proves identity (who you are). Authorization determines permissions (what you can do).
- Security Principles
  Least privilege, defense in depth, fail-safe defaults, secure defaults, secure by design.
- Threat Modeling
  Systematically enumerate assets, threats, attack surfaces, and mitigations (STRIDE, DREAD, attack trees).

2. Authentication
- Basic Authentication
  Username/password over HTTPS; simple but limited and should be avoided for APIs in favor of tokens.
- API Keys
  Static keys for service-to-service access; rotate regularly and scope permissions.
- JWT
  JSON Web Tokens for stateless auth; watch out for token revocation, expiry, and proper signing/algorithms.
- OAuth 2.0
  Delegated authorization framework for third-party access; supports multiple flows (authorization code, client credentials).
- OpenID Connect
  Identity layer on top of OAuth 2.0 for user authentication and identity claims.
- SSO
  Single Sign-On reduces password prompts but increases blast radius — protect IdP and session tokens.
- MFA
  Multi-Factor Authentication adds additional factors (TOTP, SMS, authenticator apps) to reduce credential theft risk.

3. Authorization
- RBAC
  Role-Based Access Control assigns permissions to roles; simple and effective for many use-cases.
- ABAC
  Attribute-Based Access Control uses attributes (user, resource, environment) for fine-grained policies.
- ACL
  Access Control Lists attach permissions to resources; useful in filesystem-like scenarios.
- Claims-Based Authorization
  Use tokens/claims (e.g., JWT claims) to drive authorization decisions with caution about trust boundaries.

4. Transport Security
- HTTPS
  Always use HTTPS; obtain certificates from trusted CAs and enable HSTS where appropriate.
- SSL/TLS
  Use modern TLS versions and strong cipher suites; disable outdated SSL/TLS versions and weak ciphers.
- mTLS
  Mutual TLS authenticates both client and server — useful for service-to-service authentication.
- Certificate Management
  Automate issuance and rotation (ACME/Let's Encrypt, managed services) and protect private keys.

5. Data Security
- Encryption at Rest
  Encrypt sensitive data using volume-level or application-level encryption and manage keys securely.
- Encryption in Transit
  Use TLS for network-level encryption; consider application-layer encryption for end-to-end secrecy.
- Hashing
  Use cryptographic hashes for integrity checks; prefer collision-resistant algorithms (SHA-256+).
- Salting
  Add unique salts to passwords before hashing to prevent rainbow-table attacks.
- Digital Signatures
  Sign important messages/records to verify origin and integrity (asymmetric cryptography).

6. API Security
- CORS
  Configure allowed origins and avoid overly permissive CORS policies in browsers.
- CSRF
  Protect state-changing endpoints with anti-CSRF tokens or same-site cookies for browser flows.
- XSS
  Sanitize and encode user-supplied input in HTML contexts; use Content Security Policy (CSP).
- SQL Injection
  Use parameterized queries or ORM query bindings; never concatenate user input into SQL.
- Input Validation
  Validate and canonicalize inputs on both client and server; enforce types and length limits.
- Output Encoding
  Encode data for the target context (HTML, JavaScript, URL) when reflecting user content.
- Rate Limiting
  Throttle abusive clients and protect against brute-force and API abuse; combine with monitoring and blocking.

7. Secrets Management
- API Keys / Secrets / Certificates
  Store secrets in dedicated secret stores (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault).
- Key Rotation
  Rotate keys and secrets regularly; design services to fetch secrets dynamically rather than embedding them.

8. Identity Management
- Identity Provider (IdP)
  Use well-maintained IdPs (Azure AD, Auth0, Keycloak) to delegate authentication and user lifecycle.
- Federation
  Allow trust across domains using SAML/OIDC for corporate SSO across services.
- SAML
  XML-based protocol for federated identity, often used in enterprise SSO.
- SCIM
  System for provisioning and deprovisioning user accounts across identity-aware services.

9. Infrastructure Security
- Network Security
  Use segmentation, private subnets, and least-privilege network ACLs.
- Firewall / WAF
  Protect applications at the edge and filter common web attacks with managed WAF rules.
- DDoS Protection
  Use rate-limiting, scrubbing services (CDN/WAF), and cloud provider DDoS protections.
- Zero Trust
  Assume no implicit trust; verify each request and minimize network-level trust boundaries.

10. Container & Kubernetes Security
- Image Scanning
  Scan container images for vulnerabilities and sign trusted images.
- Pod Security
  Apply Pod Security Standards, avoid running containers as root, and restrict capabilities.
- Network Policies
  Use Kubernetes NetworkPolicies or service meshes to control pod-to-pod traffic.
- RBAC
  Limit Kubernetes RBAC permissions and audit access to the cluster.
- Secrets
  Use secret stores or platform-native secret objects with encryption at rest; avoid environment-variable leakage.

11. Cloud Security
- IAM
  Implement least-privilege IAM roles and use managed identities where available.
- Security Groups
  Narrow network access with security groups and subnet restrictions.
- Managed Identity / Key Vault / KMS
  Use cloud KMS/key vaults for key lifecycle and access control to encryption keys.

12. Implementations
- Azure AD / Microsoft Entra ID, Auth0, Keycloak
  Identity solutions for authentication, SSO, and federation.
- Azure Key Vault / HashiCorp Vault
  Secret management platforms with rotation, audit, and access control.
- AWS IAM
  Identity and access management for AWS resources — use roles for services and avoid long-lived credentials.

13. Design Patterns
- Zero Trust
  Continuous verification of identity and device posture for every access.
- Defense in Depth
  Layer multiple defenses (network, host, application, data) so that single failures do not lead to compromise.
- Least Privilege
  Grant only necessary permissions and narrow scopes for tokens/roles.
- Secure by Default
  Choose secure defaults (e.g., closed ports, no admin defaults) to minimize exposure.
- Token-Based Authentication
  Use short-lived tokens with refresh flows; support revocation and rotation.

Appendix: Quick checklist for engineers
- Enforce TLS for all external traffic.
- Use managed IdP or hardened auth libraries.
- Store secrets in a vault and rotate.
- Validate inputs and encode outputs.
- Implement rate limits and monitoring/alerting for anomalous auth events.
- Regularly scan images and dependencies.
