class Ticket < ActiveRecord::Base
	has_many :tags
	has_many :users, :through => :tags
	belongs_to :asset
	belongs_to :room
	has_many :comments
	belongs_to :ticketqueue
	belongs_to :submitter, :class_name => 'User'
	attr_accessor :comment, :due_at 
	after_create :set_comment
	before_save :fix_due

	has_attached_file :attachment, :styles => {:preview => "320x240>", :small => "640x480>"}
	validates_attachment_content_type :attachment, :content_type=>['image/jpeg', 'image/png', 'image/gif']	
	scope :low, where("`tickets`.status = 1")
	scope :routine, where("status = 2")
	scope :urgent, where("status = 3")
	scope :deferred, where("status = 99")
	scope :completed, where("status = 100")
	scope :incomplete, where("status != 100")



	attr_accessible :room_id, :asset_id, :ticketqueue_id, :status, :attachment, :submitter_id, :due, :comment, :due_at

	def statusify
		return 'Low' if status==1
		return 'Routine' if status==2
		return 'Urgent' if status==3
		return 'Deferred' if status==99
		return 'Completed' if status==100
		return 'Undefined'
	end

	def assigned?
		return submitter if submitter.admin? 
		users.each do |user|
			if(user.admin?) then return user end
		end
		false
	end

	def room
		self.room_id ? Room.where(:id => self.room_id).first : asset.room
	end

	def late?
		if status != 100
			self.due ? self.due < Time.now : false
		else
			false
		end
	end

	def complete?
		self.status == 100
	end

	def set_comment
		if self.comment
			Comment.create!(:user_id => self.submitter.id, :content => self.comment, :ticket_id => self.id)
		end
		Tag.create!(:ticket_id => self.id, :user_id => self.submitter.id)
	end

	def fix_due
		if self.due_at != "" && self.due_at.is_a?(String)
			self.due_at.match /(\d+)\/(\d+)\/(\d+) (\d+):(\d+)/
			self.due = DateTime.civil($3.to_i, $1.to_i, $2.to_i, $4.to_i, $5.to_i)

		elsif self.due_at != ""
			
		end

	end


end
