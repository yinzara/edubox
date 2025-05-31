#!/usr/bin/env python3
"""
EduBox Global Impact Tracker
Monitors deployments, usage, and educational outcomes
"""

import json
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
import requests
import matplotlib.pyplot as plt
import pandas as pd

class EduBoxTracker:
    def __init__(self, db_path="edubox_impact.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Initialize tracking database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Deployments table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS deployments (
                id INTEGER PRIMARY KEY,
                location TEXT NOT NULL,
                country TEXT NOT NULL,
                install_date DATE NOT NULL,
                students_served INTEGER DEFAULT 0,
                device_id TEXT UNIQUE,
                status TEXT DEFAULT 'active',
                partner_org TEXT,
                notes TEXT
            )
        """)
        
        # Usage statistics table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS usage_stats (
                id INTEGER PRIMARY KEY,
                device_id TEXT NOT NULL,
                date DATE NOT NULL,
                unique_users INTEGER DEFAULT 0,
                total_hours REAL DEFAULT 0,
                khan_hours REAL DEFAULT 0,
                wikipedia_views INTEGER DEFAULT 0,
                video_hours REAL DEFAULT 0,
                FOREIGN KEY (device_id) REFERENCES deployments (device_id)
            )
        """)
        
        # Learning outcomes table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS learning_outcomes (
                id INTEGER PRIMARY KEY,
                device_id TEXT NOT NULL,
                student_id TEXT NOT NULL,
                assessment_date DATE NOT NULL,
                subject TEXT NOT NULL,
                pre_score REAL,
                post_score REAL,
                improvement REAL,
                FOREIGN KEY (device_id) REFERENCES deployments (device_id)
            )
        """)
        
        conn.commit()
        conn.close()
    
    def add_deployment(self, location, country, device_id, partner_org=None):
        """Register a new EduBox deployment"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO deployments (location, country, install_date, device_id, partner_org)
            VALUES (?, ?, ?, ?, ?)
        """, (location, country, datetime.now().date(), device_id, partner_org))
        
        conn.commit()
        conn.close()
        print(f"✓ Deployment registered: {location}, {country}")
    
    def update_usage(self, device_id, users, total_hours, khan_hours=0, 
                     wikipedia_views=0, video_hours=0):
        """Update daily usage statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO usage_stats 
            (device_id, date, unique_users, total_hours, khan_hours, wikipedia_views, video_hours)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (device_id, datetime.now().date(), users, total_hours, 
              khan_hours, wikipedia_views, video_hours))
        
        conn.commit()
        conn.close()
    
    def record_learning_outcome(self, device_id, student_id, subject, 
                               pre_score, post_score):
        """Record student learning outcomes"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        improvement = ((post_score - pre_score) / pre_score * 100) if pre_score > 0 else 0
        
        cursor.execute("""
            INSERT INTO learning_outcomes 
            (device_id, student_id, assessment_date, subject, pre_score, post_score, improvement)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (device_id, student_id, datetime.now().date(), subject, 
              pre_score, post_score, improvement))
        
        conn.commit()
        conn.close()
    
    def get_global_stats(self):
        """Get global impact statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Total deployments
        cursor.execute("SELECT COUNT(*) FROM deployments WHERE status = 'active'")
        total_deployments = cursor.fetchone()[0]
        
        # Countries reached
        cursor.execute("SELECT COUNT(DISTINCT country) FROM deployments")
        countries_reached = cursor.fetchone()[0]
        
        # Total students served
        cursor.execute("SELECT SUM(students_served) FROM deployments")
        total_students = cursor.fetchone()[0] or 0
        
        # Total learning hours
        cursor.execute("SELECT SUM(total_hours) FROM usage_stats")
        total_hours = cursor.fetchone()[0] or 0
        
        # Average improvement
        cursor.execute("SELECT AVG(improvement) FROM learning_outcomes")
        avg_improvement = cursor.fetchone()[0] or 0
        
        conn.close()
        
        return {
            'deployments': total_deployments,
            'countries': countries_reached,
            'students': total_students,
            'learning_hours': total_hours,
            'avg_improvement': round(avg_improvement, 1)
        }
    
    def generate_impact_report(self, output_path="impact_report.html"):
        """Generate visual impact report"""
        stats = self.get_global_stats()
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>EduBox Global Impact Report</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 40px;
            background: #f5f5f5;
        }}
        .header {{
            text-align: center;
            color: #2c3e50;
            margin-bottom: 40px;
        }}
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }}
        .stat-card {{
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
        }}
        .stat-number {{
            font-size: 2.5em;
            font-weight: bold;
            color: #3498db;
            margin: 10px 0;
        }}
        .stat-label {{
            color: #666;
            font-size: 0.9em;
        }}
        .impact-section {{
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }}
        .footer {{
            text-align: center;
            color: #666;
            margin-top: 40px;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🌍 EduBox Global Impact Report</h1>
        <p>Generated: {datetime.now().strftime('%B %d, %Y')}</p>
    </div>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label">Active Deployments</div>
            <div class="stat-number">{stats['deployments']:,}</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-label">Countries Reached</div>
            <div class="stat-number">{stats['countries']}</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-label">Students Served</div>
            <div class="stat-number">{stats['students']:,}</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-label">Learning Hours</div>
            <div class="stat-number">{stats['learning_hours']:,.0f}</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-label">Avg. Score Improvement</div>
            <div class="stat-number">{stats['avg_improvement']}%</div>
        </div>
    </div>
    
    <div class="impact-section">
        <h2>📈 Impact Highlights</h2>
        <ul>
            <li>Each EduBox serves an average of {stats['students'] // (stats['deployments'] or 1)} students</li>
            <li>Students spend an average of {stats['learning_hours'] / (stats['students'] or 1):.1f} hours learning</li>
            <li>Cost per student: ${100 * stats['deployments'] / (stats['students'] or 1):.2f}</li>
            <li>Equivalent to {stats['learning_hours'] / 1000:.0f} teacher-years of instruction</li>
        </ul>
    </div>
    
    <div class="impact-section">
        <h2>🎯 Sustainable Development Goals</h2>
        <p>EduBox directly contributes to:</p>
        <ul>
            <li><strong>SDG 4</strong>: Quality Education - Ensuring inclusive and equitable quality education</li>
            <li><strong>SDG 5</strong>: Gender Equality - Equal access to education for all genders</li>
            <li><strong>SDG 10</strong>: Reduced Inequalities - Bridging the digital divide</li>
            <li><strong>SDG 17</strong>: Partnerships - Global cooperation for education</li>
        </ul>
    </div>
    
    <div class="footer">
        <p>EduBox - Democratizing Education Globally</p>
        <p>www.edubox.org | impact@edubox.org</p>
    </div>
</body>
</html>
"""
        
        with open(output_path, 'w') as f:
            f.write(html_content)
        
        print(f"✓ Impact report generated: {output_path}")
    
    def project_impact(self, years=5):
        """Project future impact based on growth"""
        current_stats = self.get_global_stats()
        
        # Assume exponential growth
        growth_rate = 2.5  # 250% annual growth
        
        print("\n📊 EduBox Impact Projection")
        print("="*50)
        
        deployments = current_stats['deployments'] or 100
        
        for year in range(1, years + 1):
            deployments = int(deployments * growth_rate)
            students = deployments * 500  # Average 500 students per box
            
            print(f"\nYear {year}:")
            print(f"  Deployments: {deployments:,}")
            print(f"  Students Reached: {students:,}")
            print(f"  Learning Hours: {students * 50:,}")  # 50 hours/student/year
            print(f"  Cost per Student: ${(100 * deployments) / students:.2f}")

# Example usage
if __name__ == "__main__":
    tracker = EduBoxTracker()
    
    # Simulate some deployments
    tracker.add_deployment("Dar es Salaam", "Tanzania", "TZ001", "Education First NGO")
    tracker.add_deployment("Nairobi", "Kenya", "KE001", "Tech for Good")
    tracker.add_deployment("Mumbai", "India", "IN001", "Learn India Foundation")
    
    # Simulate usage data
    tracker.update_usage("TZ001", users=523, total_hours=1847, khan_hours=923)
    tracker.update_usage("KE001", users=412, total_hours=1523, khan_hours=761)
    
    # Record some learning outcomes
    tracker.record_learning_outcome("TZ001", "STU001", "Mathematics", 45, 72)
    tracker.record_learning_outcome("TZ001", "STU002", "Science", 38, 65)
    
    # Generate reports
    print("\n🌍 EduBox Global Impact Summary")
    print("="*50)
    stats = tracker.get_global_stats()
    for key, value in stats.items():
        print(f"{key.replace('_', ' ').title()}: {value}")
    
    # Generate HTML report
    tracker.generate_impact_report()
    
    # Project future impact
    tracker.project_impact()