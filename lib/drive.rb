require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'

class GDrive
  API_VERSION = 'v2'
  CACHED_API_FILE = "drive-#{API_VERSION}.cache"
 
  def initialize(credential_file_store)
    unless File.exists? credential_file_store
      puts "#{credential_file_store} does not exist"
      exit -1
    end
    @credential_file_store = credential_file_store
    setup
  end  
  
  def setup
    log_file = File.open('drive.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG
  
    @client = Google::APIClient.new(:application_name => 'GDrive App Uploader',
        :application_version => '0.0.1')
  
    file_storage = Google::APIClient::FileStorage.new(@credential_file_store)
    if file_storage.authorization.nil?
      client_secrets = Google::APIClient::ClientSecrets.load
      flow = Google::APIClient::InstalledAppFlow.new(
        :client_id => client_secrets.client_id,
        :client_secret => client_secrets.client_secret,
        :scope => ['https://www.googleapis.com/auth/drive']
      )
      @client.authorization = flow.authorize(file_storage)
    else
      @client.authorization = file_storage.authorization
    end
  
    @drive = nil
    if File.exists? CACHED_API_FILE
      File.open(CACHED_API_FILE) do |file|
        @drive = Marshal.load(file)
      end
    else
      @drive = @client.discovered_api('drive', API_VERSION)
      File.open(CACHED_API_FILE, 'w') do |file|
        Marshal.dump(@drive, file)
      end
    end
  
  end
  
  def insert_file(options)
    file_name = options.delete :file
    file = @drive.files.insert.request_schema.new(options)
  
    media = Google::APIClient::UploadIO.new(file_name, options[:mimeType])
    result = @client.execute(
      api_method: @drive.files.insert,
      body_object: file,
      media: media,
      parameters: {
        uploadType: 'multipart',
        alt: 'json'})
  
    puts result.data.to_hash
  end
end
