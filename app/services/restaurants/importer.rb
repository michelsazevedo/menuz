# frozen_string_literal: true

# Validates uploaded file and enqueues async restaurant import
class Importer
  include Result

  attributes :file

  MAX_FILE_SIZE = 10 * 1024 * 1024 # 10MB
  ALLOWED_EXTENSIONS = %w[.json].freeze

  attr_reader :errors

  def call
    @errors = Hash.new { |itself, key| itself[key] = [] }

    validate!
    return Failure(errors) if errors.any?

    upload!
    create_import!
  end

  private

  def validate!
    errors[:file] << 'Is required' unless file
    return if errors.any?

    errors[:file] << 'Invalid file extension, only .json is allowed' unless valid_extension?
    errors[:file] << 'Is too large, max 10MB' unless valid_size?
  end

  def upload!
    FileUtils.mkdir_p(imports_dir)

    @uploaded_path = File.join(imports_dir, "#{Time.now.to_i}_#{original_filename}" )

    FileUtils.cp(tempfile.path, @uploaded_path)
  end

  def create_import!
    import = Import.new(status: 'pending', file_location: @uploaded_path )

    if import.valid?
      import.save!
      ImportRestaurantsWorker.perform_async(import.id)
      Success(import.values)
    else
      Failure(import.errors)
    end
  end

  def original_filename
    file[:filename]
  end

  def tempfile
    file[:tempfile]
  end

  def valid_extension?
    ALLOWED_EXTENSIONS.include?(File.extname(original_filename).downcase)
  end

  def valid_size?
    tempfile.size <= MAX_FILE_SIZE
  end

  def imports_dir
    File.join(Sinatra::Base.settings.root, '..', 'uploads', 'imports' )
  end
end
