class RemoveScreenshotFromProject < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :results, :screenshot
  end
end
