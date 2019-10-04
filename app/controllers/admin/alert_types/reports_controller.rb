module Admin
  module AlertTypes
    class ReportsController < AdminController
      include CsvDownloader
      load_and_authorize_resource :alert_type

      DASHBOARD_HEADER = "alert_id,id,school_name,title,content_type,alert_run_on,content_created_at,priority,rating,rating_from,rating_to,average_one_year_saving_£,average_ten_year_saving_£,average_payback_years,average_capital_cost,time_of_year_relevance,email_weighting,sms_weighting,management_dashboard_alert_weighting,management_priorities_weighting,pupil_dashboard_alert_weighting,public_dashboard_alert_weighting,teacher_dashboard_alert_weighting,find_out_more_weighting,sms_active,email_active,find_out_more_active,teacher_dashboard_alert_active,pupil_dashboard_alert_active,public_dashboard_alert_active,management_dashboard_alert_active,management_priorities_active,raw_priority_data".freeze
      MANAGEMENT_HEADER = "alert_id,school_name,title,alert_run_on,content_created_at,priority,rating,rating_from,rating_to,average_one_year_saving_£,average_ten_year_saving_£,average_payback_years,average_capital_cost,time_of_year_relevance,email_weighting,sms_weighting,management_dashboard_alert_weighting,management_priorities_weighting,pupil_dashboard_alert_weighting,public_dashboard_alert_weighting,teacher_dashboard_alert_weighting,find_out_more_weighting,sms_active,email_active,find_out_more_active,teacher_dashboard_alert_active,pupil_dashboard_alert_active,public_dashboard_alert_active,management_dashboard_alert_active,management_priorities_active,raw_priority_data".freeze
      EMAIL_SMS_HEADER = "alert_id,school_name,title,communication_type,alert_run_on,content_created_at,priority,rating,rating_from,rating_to,average_one_year_saving_£,average_ten_year_saving_£,average_payback_years,average_capital_cost,time_of_year_relevance,email_weighting,sms_weighting,management_dashboard_alert_weighting,management_priorities_weighting,pupil_dashboard_alert_weighting,public_dashboard_alert_weighting,teacher_dashboard_alert_weighting,find_out_more_weighting,sms_active,email_active,find_out_more_active,teacher_dashboard_alert_active,pupil_dashboard_alert_active,public_dashboard_alert_active,management_dashboard_alert_active,management_priorities_active,raw_priority_data,communication_type".freeze

      def index
      end

      def show
        report_type = params[:id].to_sym

        output = if report_type == :dashboard
                   readings_to_csv(dashboard_report, DASHBOARD_HEADER)
                 elsif report_type == :email_sms
                   readings_to_csv(email_sms_report, EMAIL_SMS_HEADER)
                 elsif report_type == :management_priorities
                   readings_to_csv(management_priorities_report, MANAGEMENT_HEADER)
                 end

        send_data output, filename: "#{report_type.to_s.parameterize}-#{@alert_type.title.parameterize}-#{@alert_type.id}-alert-prioritisation-data.csv"
      end

      private

      def dashboard_report
        <<~QUERY
          select
          a.id as alert_id,
          s.name as school_name,
          at.title,
          CASE da.dashboard WHEN 0 THEN 'teacher dashboard'
                                WHEN 1 THEN 'pupil dashboard'
                                WHEN 2 THEN 'public dashboard'
                                WHEN 3 THEN 'management dashboard'
                                END as content_type,
          a.run_on as alert_run_on,
          cgr.created_at as content_created_at,
          da.priority,
          a.rating,
          atr.rating_from,
          atr.rating_to,
          --a.enough_data,
          --a.relevance,
          priority_data -> 'average_one_year_saving_£' AS average_one_year_saving_£,
          priority_data -> 'average_ten_year_saving_£' AS average_ten_year_saving_£,
          priority_data -> 'average_payback_years' AS average_payback_years,
          priority_data -> 'average_capital_cost' AS average_capital_cost,
          priority_data -> 'time_of_year_relevance' AS time_of_year_relevance,
          atrcv.email_weighting,
          atrcv.sms_weighting,
          atrcv.management_dashboard_alert_weighting,
          atrcv.management_priorities_weighting,
          atrcv.pupil_dashboard_alert_weighting,
          atrcv.public_dashboard_alert_weighting,
          atrcv.teacher_dashboard_alert_weighting,
          atrcv.find_out_more_weighting,
          --atr.id,
          --atr.alert_type_id,
          atr.sms_active,
          atr.email_active,
          atr.find_out_more_active,
          atr.teacher_dashboard_alert_active,
          atr.pupil_dashboard_alert_active,
          atr.public_dashboard_alert_active,
          atr.management_dashboard_alert_active,
          atr.management_priorities_active,
          a.priority_data as raw_priority_data
          from alerts a, alert_type_ratings atr, schools s, alert_types at, dashboard_alerts da, alert_type_rating_content_versions atrcv, content_generation_runs cgr
          where atrcv.replaced_by_id is null
          and da.alert_id = a.id
          and da.alert_type_rating_content_version_id = atrcv.id
          and da.content_generation_run_id = cgr.id
          and a.alert_type_id = atr.alert_type_id
          and atr.id = atrcv.alert_type_rating_id
          and a.school_id = s.id
          and at.id = a.alert_type_id
          AND a.alert_type_id = #{@alert_type.id}
          and length(a.priority_data::text) > 2
          order by school_name, at.title, cgr.created_at, da.dashboard, atr.rating_from, atr.rating_to
        QUERY
      end

      def email_sms_report
        <<~QUERY
          select distinct on (school_name, at.title, cgr.created_at, ase.communication_type, atr.rating_from, atr.rating_to)
          a.id as alert_id,
          s.name as school_name,
          at.title,
          CASE ase.communication_type WHEN 0 THEN 'email'
                                WHEN 1 THEN 'sms'
                                END as communication_type,
          a.run_on as alert_run_on,
          cgr.created_at as content_created_at,
          ase.priority,
          a.rating,
          atr.rating_from,
          atr.rating_to,
          --a.enough_data,
          --a.relevance,
          priority_data -> 'average_one_year_saving_£' AS average_one_year_saving_£,
          priority_data -> 'average_ten_year_saving_£' AS average_ten_year_saving_£,
          priority_data -> 'average_payback_years' AS average_payback_years,
          priority_data -> 'average_capital_cost' AS average_capital_cost,
          priority_data -> 'time_of_year_relevance' AS time_of_year_relevance,
          atrcv.email_weighting,
          atrcv.sms_weighting,
          atrcv.management_dashboard_alert_weighting,
          atrcv.management_priorities_weighting,
          atrcv.pupil_dashboard_alert_weighting,
          atrcv.public_dashboard_alert_weighting,
          atrcv.teacher_dashboard_alert_weighting,
          atrcv.find_out_more_weighting,
          --atr.id,
          --atr.alert_type_id,
          atr.sms_active,
          atr.email_active,
          atr.find_out_more_active,
          atr.teacher_dashboard_alert_active,
          atr.pupil_dashboard_alert_active,
          atr.public_dashboard_alert_active,
          atr.management_dashboard_alert_active,
          atr.management_priorities_active,
          a.priority_data as raw_priority_data,
          ase.communication_type
          from alerts a, alert_type_ratings atr, schools s, alert_types at, alert_subscription_events ase, alert_type_rating_content_versions atrcv, content_generation_runs cgr
          where atrcv.replaced_by_id is null
          and ase.alert_id = a.id
          and ase.alert_type_rating_content_version_id = atrcv.id
          and ase.content_generation_run_id = cgr.id
          and a.alert_type_id = atr.alert_type_id
          and atr.id = atrcv.alert_type_rating_id
          and a.school_id = s.id
          and at.id = a.alert_type_id
          AND a.alert_type_id = #{@alert_type.id}
          and length(a.priority_data::text) > 2
          order by school_name, at.title, cgr.created_at, ase.communication_type, atr.rating_from, atr.rating_to
        QUERY
      end

      def management_priorities_report
        <<~QUERY
          select
          a.id as alert_id,
          s.name as school_name,
          at.title,
          a.run_on as alert_run_on,
          cgr.created_at as content_created_at,
          mp.priority,
          a.rating,
          atr.rating_from,
          atr.rating_to,
          --a.enough_data,
          --a.relevance,
          priority_data -> 'average_one_year_saving_£' AS average_one_year_saving_£,
          priority_data -> 'average_ten_year_saving_£' AS average_ten_year_saving_£,
          priority_data -> 'average_payback_years' AS average_payback_years,
          priority_data -> 'average_capital_cost' AS average_capital_cost,
          priority_data -> 'time_of_year_relevance' AS time_of_year_relevance,
          atrcv.email_weighting,
          atrcv.sms_weighting,
          atrcv.management_dashboard_alert_weighting,
          atrcv.management_priorities_weighting,
          atrcv.pupil_dashboard_alert_weighting,
          atrcv.public_dashboard_alert_weighting,
          atrcv.teacher_dashboard_alert_weighting,
          atrcv.find_out_more_weighting,
          --atr.id,
          --atr.alert_type_id,
          atr.sms_active,
          atr.email_active,
          atr.find_out_more_active,
          atr.teacher_dashboard_alert_active,
          atr.pupil_dashboard_alert_active,
          atr.public_dashboard_alert_active,
          atr.management_dashboard_alert_active,
          atr.management_priorities_active,
          a.priority_data as raw_priority_data
          from alerts a, alert_type_ratings atr, schools s, alert_types at, management_priorities mp, alert_type_rating_content_versions atrcv, content_generation_runs cgr
          where atrcv.replaced_by_id is null
          and mp.alert_id = a.id
          and mp.alert_type_rating_content_version_id = atrcv.id
          and mp.content_generation_run_id = cgr.id
          and a.alert_type_id = atr.alert_type_id
          and atr.id = atrcv.alert_type_rating_id
          and a.school_id = s.id
          and at.id = a.alert_type_id
          AND a.alert_type_id = #{@alert_type.id}
          and length(a.priority_data::text) > 2
          order by school_name, at.title, cgr.created_at, atr.rating_from, atr.rating_to
        QUERY
      end
    end
  end
end
