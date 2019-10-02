class MoveDataFeedRelationshipToArea < ActiveRecord::Migration[5.2]
  def up
    add_reference :areas, :data_feed, foreign_key: {on_delete: :restrict}
    connection.execute(
      'UPDATE areas SET data_feed_id = data_feeds.id FROM data_feeds WHERE data_feeds.area_id = areas.id'
    )
    remove_column :data_feeds, :area_id
  end

  def down
    add_reference :data_feeds, :area, foreign_key: {on_delete: :cascade}
    connection.execute(
      'UPDATE data_feeds SET area_id = data_feeds.id FROM areas WHERE areas.data_feed_id = data_feeds.id'
    )
    remove_column :areas, :data_feed_id
  end

end
