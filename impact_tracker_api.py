#!/usr/bin/env python3
"""
EduBox Impact Tracker API
Simple Flask wrapper for the impact tracking functionality
"""

from flask import Flask, jsonify, request
import json
import os
import sys

# Add the parent directory to the path to import impact_tracker
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from impact_tracker import EduBoxTracker

app = Flask(__name__)
tracker = EduBoxTracker(db_path="/opt/edubox/logs/edubox_impact.db")

@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "impact-tracker"})

@app.route('/api/stats')
def get_stats():
    """Get global statistics"""
    try:
        stats = tracker.get_global_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/deployment', methods=['POST'])
def add_deployment():
    """Register a new deployment"""
    try:
        data = request.json
        tracker.add_deployment(
            location=data['location'],
            country=data['country'],
            device_id=data['device_id'],
            partner_org=data.get('partner_org')
        )
        return jsonify({"status": "success", "message": "Deployment registered"})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/api/usage', methods=['POST'])
def update_usage():
    """Update usage statistics"""
    try:
        data = request.json
        tracker.update_usage(
            device_id=data['device_id'],
            users=data['users'],
            total_hours=data['total_hours'],
            khan_hours=data.get('khan_hours', 0),
            wikipedia_views=data.get('wikipedia_views', 0),
            video_hours=data.get('video_hours', 0)
        )
        return jsonify({"status": "success", "message": "Usage updated"})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/api/report')
def generate_report():
    """Generate impact report"""
    try:
        report_path = "/opt/edubox/logs/impact_report.html"
        tracker.generate_impact_report(output_path=report_path)
        return jsonify({
            "status": "success",
            "message": "Report generated",
            "path": report_path
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=False)
