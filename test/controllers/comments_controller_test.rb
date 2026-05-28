# test/controllers/comments_controller_test.rb
require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:inspector_one)
    post session_url, params: { session: {
      email_address: @user.email_address,
      password: "password123"
    }}
    @record = Record.create!(
      id: "101::Puerta habitacion::Marco",
      room: "101", category: "Puerta habitacion",
      item: "Marco", status: :completado, report_date: Date.today,
      user: @user
    )
  end

  test "crea comentario vinculado al record y al usuario actual" do
    assert_difference "Comment.count", 1 do
      post record_comments_url(@record),
           params: { comment: { body: "Número deteriorado, hay que cambiar", status: "defectuoso" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    comment = Comment.last
    assert_equal @record, comment.record
    assert_equal @user,   comment.user
    assert_equal "Número deteriorado, hay que cambiar", comment.body
    assert comment.defectuoso?
  end

  test "crea comentario sin body (entrada automática)" do
    assert_difference "Comment.count", 1 do
      post record_comments_url(@record),
           params: { comment: { status: "completado" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert Comment.last.body.blank?
  end

  test "responde con turbo stream" do
    post record_comments_url(@record),
         params: { comment: { body: "Test", status: "pendiente" } },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "el turbo stream reemplaza la tarjeta completa del record" do
    post record_comments_url(@record),
         params: { comment: { body: "Anotación", status: "pendiente" } },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_turbo_stream action: "replace", target: @record.frame_id
  end
end
