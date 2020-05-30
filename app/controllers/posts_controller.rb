class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  def confirm
    @post=Post.find_by(id:params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    if Post.last.present?
      next_id = Post.last.id + 1
    else
      next_id = 1
    end
    
    make_picture(next_id)

    if @post.save
      redirect_to confirm_path(@post)
    else
      render :new
    end

  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      make_picture(@post.id)
      redirect_to confirm_path(@post)
    else
      render :edit
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:content, :picture, :kind)
    end

    def make_picture(id)

      sentense = ""
      content = @post.content.gsub(/\r\n|\r|\n/," ")

      if content.length <= 28 then

        n = (content.length / 7).floor + 1
        n.times do |i|
          s_num = i * 7
          f_num = s_num + 6
          range = Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end

        pointsize = 90

      elsif content.length <= 50 then
        n = (content.length / 10).floor + 1
        n.times do |i|
          s_num = i * 10
          f_num = s_num + 9
          range = Range.new(s_num,f_num)
          sentence+= content.slice(range)
          sentence+= "\n" if n != i+1
        end

        pointsize = 60

      else
        n = (content.length / 15).floor + 1
        n.times do |i|
          s_num = i * 15
          f_num = s_num + 14
          range = Range.new(s_num,f_num)
          sentence += content.slice(range)
          sentence += "\n" if n != i+1
        end

        pointsize = 45

      end

      color = "white"
      draw = "text 0,0 '#{sentense}'"
      font = ".font/GenEiGothicN-U-KL.otf"

      case @post.kind
      when "black" then
        base = "app/assets/images/black.jpg"
      else
        base = "app/assets/images/red.jpg"
      end

      image = MiniMagick::Image.open(base)
      image.combine_options do |i|
        i.font font
        i.fill color
        i.gravity 'center'
        i.pointsize pointsize
        i.draw draw
      end

      storage = Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: ENV['AWS_REGION']
      )

      case Rails.env
       when 'production'
        bucket = storage.directories.get(ENV['AWS_PRODUCTION_BUCKET'])
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path 
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/' + ENV['AWS_PRODUCTION_BUCKET'] + '/' + png_path
       when 'development'
        bucket = storage.directories.get(ENV['AWS_PRODUCTION_BUCKET'])
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path 
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/' + ENV['AWS_PRODUCTION_BUCKET'] + '/' + png_path
      end

    end

    
    
end
