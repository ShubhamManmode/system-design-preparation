# Core Components

    1. Load Balancer
        Fundamentals
        Types
            Layer 4
            Layer 7
        Algorithms
            Round Robin
            Least Connections
            Weighted Round Robin
            IP Hash
        Features
            Health Checks
            Sticky Sessions
            SSL Termination
        Implementations
            NGINX
            HAProxy
            Envoy
            AWS ALB
            AWS NLB
            Azure Load Balancer
            Azure Application Gateway
        Patterns
            Active-Active
            Active-Passive
            Global Load Balancing

    2. Reverse Proxy
        Fundamentals
        Internal Working
        Features
            Routing
            SSL Termination
            Compression
            URL Rewriting
            Caching
        Implementations
            NGINX
            Envoy
            Traefik
            Apache
        Patterns
            API Gateway
            Edge Proxy
            Sidecar Proxy

    3. CDN
        Fundamentals
        Internal Working
        Components
            Edge Server
            PoP
            Origin Server
        Cache Strategies
        Cache Invalidation
        Implementations
            Cloudflare
            CloudFront
            Azure CDN
            Fastly
        Patterns
            Edge Caching
            Geo Distribution
            Origin Shield

    4. Caching
        Fundamentals
        Internal Working
        Cache Types
        Eviction Algorithms
            LRU
            LFU
            FIFO
            TTL
        Cache Patterns
            Cache Aside
            Read Through
            Write Through
            Write Back
            Write Around
            Refresh Ahead
        Distributed Cache
        Implementations
            Redis
            Memcached
            Caffeine

    5. Message Queue
        Fundamentals
        Internal Working
        Queue vs Pub/Sub
        Delivery Guarantees
        Ordering
        Retry
        Dead Letter Queue
        Implementations
            Kafka
            RabbitMQ
            ActiveMQ
            Azure Service Bus
            AWS SQS
        Patterns
            Event-Driven Architecture
            Producer-Consumer
            Fan-Out
            Event Sourcing


    6. Search Engine
        Fundamentals
        Internal Working
        Inverted Index
        Ranking
        Tokenization
        Stemming
        Fuzzy Search
        Implementations
            Elasticsearch
            OpenSearch
            Solr
        Patterns
            Full-Text Search
            Autocomplete
            Search Suggestions
        Real-world Examples
            Amazon Search
            Google Search
            LinkedIn Search
        Interview Problems

    7. Object Storage
        Fundamentals
        Internal Working
        Object Model
        Metadata
        Versioning
        Multipart Upload
        Lifecycle Policies
        Implementations
            Amazon S3
            Azure Blob Storage
            Google Cloud Storage
            MinIO
        Patterns
            Data Lake
            Backup Storage
            Static Asset Storage

    8. Rate Limiter
        Fundamentals
        Algorithms
            Token Bucket
            Leaky Bucket
            Fixed Window
            Sliding Window
        Distributed Rate Limiting
        Implementations
            Redis
            NGINX
            Envoy
            API Gateway
        Patterns
            API Protection
            User Quotas
            DDoS Protection
        Real-world Examples
            Stripe
            GitHub API
        Interview Problems

    9. Scheduler
        Fundamentals
        Internal Working
        Scheduling Types
        Distributed Scheduling
        Retry
        Implementations
            Quartz
            Hangfire
            Kubernetes CronJob
            Airflow
        Patterns
            Batch Processing
            Periodic Jobs
            Delayed Jobs
 
    10. Notification System
        Fundamentals
        Internal Working
        Channels
            Push
            Email
            SMS
            Webhooks
        Retry Strategy
        Implementations
            Firebase FCM
            APNs
            SendGrid
            Twilio
        Patterns
            Fan-Out
            Pub/Sub
            Event-Driven
        Real-world Examples
            WhatsApp
            Instagram
            Gmail
        Interview Problems