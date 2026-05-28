# test/models/comment_test.rb
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = users(:inspector_one)
    @record = Record.create!(
      id: "101::Puerta habitacion::Marco",
      room: "101", category: "Puerta habitacion",
      item: "Marco", status: :pendiente, report_date: Date.today,
      user: @user
    )
  end

  test "valid with record, user and status" do
    comment = Comment.new(record: @record, user: @user, status: :pendiente)
    assert comment.valid?
  end

  test "invalid without record_id" do
    comment = Comment.new(user: @user, status: :pendiente)
    assert comment.invalid?
    assert_includes comment.errors[:record], "must exist"
  end

  test "invalid without user" do
    comment = Comment.new(record: @record, status: :pendiente)
    assert comment.invalid?
    assert_includes comment.errors[:user], "must exist"
  end

  test "body can be blank (auto-generated comments have no body)" do
    comment = Comment.new(record: @record, user: @user, status: :completado, body: nil)
    assert comment.valid?
  end

  test "default status is pendiente" do
    comment = Comment.new(record: @record, user: @user)
    assert comment.pendiente?
  end

  test "supports defectuoso and completado statuses" do
    defective = Comment.new(record: @record, user: @user, status: :defectuoso)
    complete  = Comment.new(record: @record, user: @user, status: :completado)
    assert defective.defectuoso?
    assert complete.completado?
  end

  test "chronological scope orders by created_at asc" do
    c1 = Comment.create!(record: @record, user: @user, status: :pendiente)
    c2 = Comment.create!(record: @record, user: @user, status: :completado)
    assert_equal [ c1, c2 ], @record.comments.chronological.to_a
  end

  test "record has_many comments" do
    Comment.create!(record: @record, user: @user, status: :pendiente, body: "Observación")
    assert_equal 1, @record.comments.count
  end

  test "destroying record cascades to comments" do
    Comment.create!(record: @record, user: @user, status: :pendiente)
    assert_difference "Comment.count", -1 do
      @record.destroy
    end
  end
end
