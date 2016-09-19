class AddScreenshotToResult < ActiveRecord::Migration[5.0]
  def up
    add_attachment :results, :screenshot
  end

  def down
    remove_attachment :results, :screenshot
  end
end
