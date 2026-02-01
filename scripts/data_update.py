import firebase_admin
from firebase_admin import credentials, firestore
import random

cred = credentials.Certificate("D:/Work/note/study_aid/scripts/study-aid-e3671-firebase-adminsdk-9b01y-8d5c0e0d6b.json")
firebase_admin.initialize_app(cred)

# Get a Firestore client
db = firestore.client()

def generate_random_color():
    """Generate a random color in hex format."""
    return "#{:02x}{:02x}{:02x}".format(random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))

# Color codes for printing
class Colors:
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    CYAN = "\033[36m"
    MAGENTA = "\033[35m"
    RESET = "\033[0m"

def print_colored(message, color):
    """Helper function to print messages in color."""
    print(f"{color}{message}{Colors.RESET}")

def update_user_data():
    try:
        # Reference to the users collection
        users_ref = db.collection('users')

        # List all user documents
        users = users_ref.stream()

        topics_to_remove = []

        for user in users:
            print_colored(f"Processing user: {user.id}", Colors.GREEN)

            # Access the 'createdTopics' field for each user
            user_data = user.to_dict()
            if 'createdTopics' in user_data:
                created_topics_refs = user_data['createdTopics']
                print_colored(f"\tProcessing created topics for user {user.id}: {created_topics_refs}", Colors.CYAN)
                
                # Iterate through each topic reference (doc ID)
                for topic_id in created_topics_refs:
                    topic_ref = db.collection('topics').document(topic_id)  # Get reference to the topic
                    topic = topic_ref.get()  # Fetch the topic document using the reference
                    
                    if topic.exists:
                        topic_data = topic.to_dict()
                        print_colored(f"\t\tProcessing topic: {topic.id}", Colors.YELLOW)

                        # Check if 'userId' field exists in the topic, if not, add it
                        if 'userId' not in topic_data:
                            topic_ref.update({'userId': user.id})
                            print_colored(f"\t\t\tAdded 'userId' to topic {topic.id}", Colors.MAGENTA)

                        # Check subtopics, notes, and audioRecording for each topic
                        update_subtopics_notes_audio(topic, user.id, topic_ref)
                    else:
                        # If subtopic no longer exists, mark for removal
                        topics_to_remove.append(topic.id)

            if topics_to_remove:
                # print(f"\t\tRemoved invalid createdTopics references from user {user.id}")
                # user_ref = db.collection('users').document(user.id)
                # user_ref.update({
                #     'createdTopics': firestore.ArrayRemove(topics_to_remove)
                # })
                print_colored(f"\t\tRemoved invalid createdTopics references from user {user.id} -> {topics_to_remove}", Colors.RED)

    except Exception as e:
        print_colored(f"Error updating Firestore: {e}", Colors.RED)

def update_subtopics_notes_audio(topic, user_id, topic_ref):
    try:
        # Access topic data and check for subtopics, notes, and audioRecording fields
        topic_data = topic.to_dict()

        # Update subtopics if they exist
        if 'subtopics' in topic_data:
            subtopics_to_remove = []
            for subtopic_id in topic_data['subtopics']:
                subtopic_ref = db.collection('topics').document(subtopic_id)  # Get subtopic reference
                subtopic = subtopic_ref.get()  # Get the subtopic document
                if subtopic.exists:
                    update_topic_fields(subtopic, user_id, subtopic_ref)
                else:
                    # If subtopic no longer exists, mark for removal
                    subtopics_to_remove.append(subtopic_id)

            # Remove invalid subtopic references from the 'subtopics' list
            if subtopics_to_remove:
                # topic_ref.update({
                #     'subtopics': firestore.ArrayRemove(subtopics_to_remove)
                # })
                print_colored(f"    Removed invalid subtopic references from topic {topic.id}", Colors.RED)

        # Update notes if they exist
        if 'notes' in topic_data:
            notes_to_remove = []
            for note_id in topic_data['notes']:
                note_ref = db.collection('notes').document(note_id)  # Get subtopic reference
                note = note_ref.get()  # Get the note document using the reference
                if note.exists:
                    update_item_fields(note, user_id, 'note', note_ref)
                else:
                    # If note no longer exists, mark for removal
                    notes_to_remove.append(note_id)

            # Remove invalid note references from the 'notes' list
            if notes_to_remove:
                # topic_ref.update({
                #     'notes': firestore.ArrayRemove(notes_to_remove)
                # })
                print_colored(f"    Removed invalid note references from topic {topic.id}", Colors.RED)

        # Update audioRecordings if they exist
        if 'audioRecording' in topic_data:
            audio_to_remove = []
            for audio_id in topic_data['audioRecording']:
                audio_ref = db.collection('audios').document(audio_id)
                audio = audio_ref.get()  # Get the audio document using the reference
                if audio.exists:
                    update_item_fields(audio, user_id, 'audioRecording', audio_id)
                else:
                    # If audio recording no longer exists, mark for removal
                    audio_to_remove.append(audio_id)

            # Remove invalid audio references from the 'audioRecording' list
            if audio_to_remove:
                # topic_ref.update({
                #     'audioRecording': firestore.ArrayRemove(audio_to_remove)
                # })
                print_colored(f"    Removed invalid audio references from topic {topic.id}", Colors.RED)

    except Exception as e:
        print_colored(f"Error updating subtopics/notes/audio: {e}", Colors.RED)

def update_topic_fields(subtopic, user_id, subtopic_ref):
    """Recursive function to update subtopics, notes, and audioRecordings of a subtopic"""
    subtopic_data = subtopic.to_dict()
    
    if 'userId' not in subtopic_data:
        subtopic_ref.update({'userId': user_id})
        print_colored(f"\t\t\t\tAdded 'userId' to subtopic {subtopic.id}", Colors.YELLOW)
        update_subtopics_notes_audio(subtopic, user_id, subtopic_ref)

def update_item_fields(item, user_id, item_type, item_ref):
    """Helper function to update the userId in subtopics, notes, or audioRecordings"""
    item_data = item.to_dict()
    
    if 'userId' not in item_data:
        item_ref.update({'userId': user_id})
        print_colored(f"\t\t\t\tAdded 'userId' to {item_type} {item.id}", Colors.YELLOW)
        print_colored(f"\t\t\t\t\t{item_type} updated: {item.id}", Colors.YELLOW)

# Run the function to update data
update_user_data()
