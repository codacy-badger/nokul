# frozen_string_literal: true

require 'test_helper'

class LdapSyncJobTest < ActiveJob::TestCase
  test 'can enqueue Ldap::SyncJob' do
    assert_enqueued_jobs 0
    Ldap::SyncJob.perform_later(ldap_entities(:one))
    assert_enqueued_jobs 1
  end

  test 'can perform enqueued jobs for Ldap::SyncJob' do
    assert_no_performed_jobs

    assert_performed_jobs 1 do
      Ldap::SyncJob.perform_later(ldap_entities(:one))
    end
  end

  test 'Ldap::SyncJob runs in the high priority queue' do
    assert_equal Ldap::SyncJob.new.queue_name, 'high'
  end
end