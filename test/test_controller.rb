require_relative 'mock_view'

require_relative '../controller/controller'

class TestController

    def self.test_controller
        tv = MockView.new
        cont = Controller.new([tv], :OttoNToot, false)

        cont.update_model(3)
        cont.update_model(4)
        cont.update_model(6)
        cont.update_model(3)
        cont.update_model(3)

        puts tv
    end
end

TestController.test_controller