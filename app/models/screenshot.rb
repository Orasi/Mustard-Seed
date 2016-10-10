class Screenshot < ApplicationRecord

  has_attached_file :screenshot,
                    url: ':project_name/:execution_date/:test_name/:result_file_name',
                    path: "/#{::Rails.root}/screenshots/:project_name/:execution_date/:test_name/:result_file_name"

  validates_attachment_content_type :screenshot, content_type: /\Aimage\/.*\z/
  validates :execution_start, :testcase_name, :environment_uuid, :project_name, presence: true

  Paperclip.interpolates('project_name') do |attachment, style|
    attachment.instance.project_name
  end

  Paperclip.interpolates('execution_date') do |attachment, style|
    attachment.instance.execution_start.strftime('%m-%d-%Y')
  end

  Paperclip.interpolates('test_name') do |attachment, style|
    attachment.instance.testcase_name
  end

  Paperclip.interpolates('result_file_name') do |attachment, style|
    "screenshot_#{attachment.instance.id}-#{attachment.instance.environment_uuid}.png"
  end

end
