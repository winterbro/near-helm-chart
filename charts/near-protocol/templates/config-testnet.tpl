{{- define "near-node.config.testnet" -}}
genesis_file: genesis.json
genesis_records_file:
validator_key_file: validator_key.json
node_key_file: node_key.json
rpc:
  addr: 0.0.0.0:3030
  prometheus_addr:
  cors_allowed_origins:
  - "*"
  polling_config:
    polling_interval:
      secs: 0
      nanos: 500000000
    polling_timeout:
      secs: 10
      nanos: 0
  limits_config:
    json_payload_max_size: 10485760
  enable_debug_rpc: true
  experimental_debug_pages_src_path:
telemetry:
  endpoints:
  - https://explorer.testnet.near.org/api/nodes
  reporting_interval:
    secs: 10
    nanos: 0
network:
  addr: 0.0.0.0:24567
  boot_nodes: ed25519:4k9csx6zMiXy4waUvRMPTkEtAS2RFKLVScocR5HwN53P@34.73.25.182:24567,ed25519:4keFArc3M4SE1debUQWi3F1jiuFZSWThgVuA2Ja2p3Jv@34.94.158.10:24567,ed25519:D2t1KTLJuwKDhbcD9tMXcXaydMNykA99Cedz7SkJkdj2@35.234.138.23:24567,ed25519:CAzhtaUPrxCuwJoFzceebiThD9wBofzqqEMCiupZ4M3E@34.94.177.51:24567
  whitelist_nodes: ''
  max_num_peers: 40
  minimum_outbound_peers: 5
  ideal_connections_lo: 30
  ideal_connections_hi: 35
  peer_recent_time_window:
    secs: 600
    nanos: 0
  safe_set_size: 20
  archival_peer_connections_lower_bound: 10
  handshake_timeout:
    secs: 20
    nanos: 0
  skip_sync_wait: false
  ban_window:
    secs: 10800
    nanos: 0
  blacklist: []
  ttl_account_id_router:
    secs: 3600
    nanos: 0
  peer_stats_period:
    secs: 5
    nanos: 0
  monitor_peers_max_period:
    secs: 60
    nanos: 0
  peer_states_cache_size: 1000
  peer_expiration_duration:
    secs: 604800
    nanos: 0
  public_addrs: []
  allow_private_ip_in_public_addrs: false
  trusted_stun_servers:
  - stun.l.google.com:19302
  - stun1.l.google.com:19302
  - stun2.l.google.com:19302
  - stun3.l.google.com:19302
  - stun4.l.google.com:19302
  experimental:
    inbound_disabled: false
    connect_only_to_boot_nodes: false
    skip_sending_tombstones_seconds: 0
    tier1_enable_inbound: true
    tier1_enable_outbound: true
    tier1_connect_interval:
      secs: 60
      nanos: 0
    tier1_new_connections_per_attempt: 50
consensus:
  min_num_peers: 3
  block_production_tracking_delay:
    secs: 0
    nanos: 100000000
  min_block_production_delay:
    secs: 1
    nanos: 0
  max_block_production_delay:
    secs: 2
    nanos: 500000000
  max_block_wait_delay:
    secs: 6
    nanos: 0
  produce_empty_blocks: true
  block_fetch_horizon: 50
  block_header_fetch_horizon: 50
  catchup_step_period:
    secs: 0
    nanos: 100000000
  chunk_request_retry_period:
    secs: 0
    nanos: 400000000
  header_sync_initial_timeout:
    secs: 10
    nanos: 0
  header_sync_progress_timeout:
    secs: 2
    nanos: 0
  header_sync_stall_ban_timeout:
    secs: 120
    nanos: 0
  state_sync_timeout:
    secs: 60
    nanos: 0
  header_sync_expected_height_per_second: 10
  sync_check_period:
    secs: 10
    nanos: 0
  sync_step_period:
    secs: 0
    nanos: 10000000
  doomslug_step_period:
    secs: 0
    nanos: 100000000
  sync_height_threshold: 1
tracked_accounts: []
tracked_shards:
- 0
log_summary_style: colored
log_summary_period:
  secs: 10
  nanos: 0
enable_multiline_logging: true
gc_blocks_limit: 2
gc_fork_clean_step: 100
gc_num_epochs_to_keep: 5
view_client_threads: 4
epoch_sync_enabled: false
view_client_throttle_period:
  secs: 30
  nanos: 0
trie_viewer_state_size_limit: 50000
store:
  path: 
  enable_statistics: false
  enable_statistics_export: true
  max_open_files: 10000
  col_state_cache_size: 536870912
  block_size: 16384
  trie_cache:
    default_max_bytes: 50000000
    per_shard_max_bytes:
      s3.v1: 3000000000
    shard_cache_deletions_queue_capacity: 100000
  view_trie_cache:
    default_max_bytes: 50000000
    per_shard_max_bytes: {}
    shard_cache_deletions_queue_capacity: 100000
  enable_receipt_prefetching: true
  sweat_prefetch_receivers:
  - token.sweat
  - vfinal.token.sweat.testnet
  sweat_prefetch_senders:
  - oracle.sweat
  - sweat_the_oracle.testnet
  claim_sweat_prefetch_config:
  - receiver: claim.sweat
    sender: token.sweat
    method_name: record_batch_for_hold
  - receiver: claim.sweat
    sender: ''
    method_name: claim
  background_migration_threads: 8
  flat_storage_creation_enabled: true
  flat_storage_creation_period:
    secs: 1
    nanos: 0
  state_snapshot_enabled: false
  state_snapshot_compaction_enabled: false
state_sync_enabled: true
state_sync:
  sync:
    ExternalStorage:
      location:
        GCS:
          bucket: state-parts
      num_concurrent_requests: 25
      num_concurrent_requests_during_catchup: 5
transaction_pool_size_limit: 100000000
{{- end}}
