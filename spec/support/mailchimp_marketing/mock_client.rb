module MailchimpMarketing
  class MockList
    def get_all_lists
      []
    end
  end
  class MockClient
    def lists
      MockList.new
    end
  end
end

