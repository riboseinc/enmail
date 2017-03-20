module Mail::Secure

  # Include this in your mailer class
  module PGPMailable

    require 'active_support/concern'
    extend ActiveSupport::Concern

    module InstanceMethods

      # TODO: extract this out for use on a lower level - i.e. not specific to
      # Rails / ActionMailer.
      # Boolean: true iff we want to enable signing of emails, false iff we
      # want to disable it.
      def sign_emails?
        # TODO: fetch from config
      end

      # TODO: extract this out for use on a lower level - i.e. not specific to
      # Rails / ActionMailer.
      # Has the following properties:
      #  - email
      #  - fingerprint
      #  - user ids
      #  - key body
      def active_key
        # TODO: fetch from config
      end

      # TODO: extract this out for use on a lower level - i.e. not specific to
      # Rails / ActionMailer.
      # Implement this!
      def key_url
        'IMPLEMENT THIS'
      end

      # TODO: extract this out for use on a lower level - i.e. not specific to
      # Rails / ActionMailer.
      def add_pgp_headers(headers)
        return headers unless sign_emails? && active_key

        key_fingerprint = active_key.fingerprint

        headers.merge(
          gpg: {
            sign:    true,
            sign_as: active_key.email,
          },

          # https://www.ietf.org/archive/id/draft-josefsson-openpgp-mailnews-header-07.txt
          'X-PGP-Key': key_url,
          OpenPGP: {
            url: key_url,
            id:  key_fingerprint,
          }.map{|k, v| "#{k}=#{v};"}.join(" ")
        )

      rescue StandardError => e
        if Rails.env.test?
          raise e
        end
        Rails.logger.error "[PGPMailable] Error unable to sign emails: #{e.message} #{e.backtrace}"
        headers
      end

      # NOTE: This can remain in PGPMailable because it's specific to
      # ActionMailer.
      def mail headers={}, &block
        # puts "what are headers? #{add_pgp_headers(headers).pretty_inspect}"
        super(add_pgp_headers(headers), &block).tap do |m|
          # puts m.to_s
        end
      end

    end

    included do

      def self.apply(base=self)

        # You can't use .prepend on ActionMailer::Base, oh no you can't!
        add_to = case base
        when ActionMailer::Base
          :include
        else :prepend
        end

        unless base < InstanceMethods
          self.send add_to, Mail::Gpg::Rails::ActionMailerPatch::InstanceMethods
          self.send add_to, InstanceMethods
          # self.singleton_class.send add_to, Mail::Gpg::Rails::ActionMailerPatch::ClassMethods
        end
      end

      apply

      # This would override the original .extended
      # def self.extended(base)
      #   puts " sooo #{self}.extended #{base}"
      #   apply base
      #   super
      # end

    end

  end
end
